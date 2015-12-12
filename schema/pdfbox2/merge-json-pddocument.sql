/*
 *  Synopsis:
 *	merge jsonorg putPDDocument json objects into pdfbox2.pddocument tables
 *  Usage:
 *	psql -f merge-json-pddocument.sql --variable=since="'-1 day'"
 */

\echo merging all putPDDocument since :since

\timing on
\set ON_ERROR_STOP on

CREATE TEMP TABLE merge_pddocument AS
WITH find_pddocument AS (
  SELECT
  	blob AS jblob,
  	doc->'pdfbox2.setspace.com'->'putPDDocument' AS doc
  FROM
  	jsonorg.jsonb_255
	  NATURAL JOIN setspace.service s
  WHERE
  	doc @> '{
	    "pdfbox2.setspace.com": {
	      "putPDDocument": {}
	    }
	}'
	AND
	s.discover_time > now() + :since
), json2row AS (
    SELECT
	jblob,
	blob,
	exit_status,
	number_of_pages,
	document_id,
	version,
	is_all_security_to_be_removed,
	is_encrypted,
	stderr_blob
    FROM
	find_pddocument,
	  LATERAL jsonb_to_record(doc) AS j2r(
		blob udig,
		exit_status smallint,
		number_of_pages int,
		document_id bigint,
		version float,
		is_all_security_to_be_removed bool,
		is_encrypted bool,
		stderr_blob udig
	  )
)
SELECT
	*,
	'New Tuple'::text AS "syncability"
  FROM
  	json2row
;

\echo indexing merge_pddocument(blob)
CREATE index merge_pddocument_idx_blob on merge_pddocument(blob);

\echo indexing merge_pddocument(jblob)
CREATE unique index merge_pddocument_idx_json on merge_pddocument(jblob);

\echo indexing merge_pddocument(syncability)
CREATE index merge_pddocument_idx_sync on merge_pddocument(syncability);

\echo analyze merge_pddocument
ANALYZE merge_pddocument;

\echo tagging blobs already merged
UPDATE merge_pddocument m1
  SET
  	syncability = 'JSON PDDocument Tuple Exists'
  WHERE
  	EXISTS (
	  SELECT
	  	m2.blob
	  FROM
	  	pdfbox2.pddocument m2
	  WHERE
	  	m2.blob = m1.blob
	)
	AND
	m1.syncability = 'New Tuple'
;

\echo reanalyze merge_pddocument after PDDocument Tuple Exists
VACUUM ANALYZE merge_pddocument;

\echo tagging blobs with no primary key reference in setspace.service
UPDATE merge_pddocument m
  set
  	syncability = 'No Primary Key in setspace.service'
  where
  	NOT EXISTS (
	  SELECT
	  	s.blob
	    FROM
	    	setspace.service s
	    WHERE
	    	s.blob = m.blob
	)
	AND
	m.syncability = 'New Tuple'
;
\echo reanalyze merge_pddocument after No Primary Key in setspace.service
VACUUM ANALYZE merge_pddocument;

\echo tagging duplicate blobs in different json runs not yet merged
UPDATE merge_pddocument m1
  SET
  	syncability = 'Duplicate'
  WHERE
  	EXISTS (
	  SELECT
	  	m2.blob
	  FROM
	  	merge_pddocument m2
	  WHERE
	  	m2.blob = m1.blob
		AND
		m2.jblob != m1.jblob
	)
	AND
	m1.syncability = 'New Tuple'
;
\echo reanalyze merge_pddocument after Duplicate
VACUUM ANALYZE merge_pddocument;

\echo summarizing merge pddocument set since :since
SELECT
	syncability,
	count(*) AS "JSON Tuple Count"
  FROM
  	merge_pddocument
  GROUP BY
  	1
  ORDER BY
  	syncability = 'New Tuple' desc,
	"JSON Tuple Count" desc
;

\echo begin merge into table pdfbox2.pddocument
INSERT INTO pdfbox2.pddocument(
	blob,
	exit_status,
	number_of_pages,
	document_id,
	version,
	is_all_security_to_be_removed,
	is_encrypted
) SELECT
	blob,
	exit_status,
	number_of_pages,
	document_id,
	version,
	is_all_security_to_be_removed,
	is_encrypted
    FROM
    	merge_pddocument
    WHERE
    	syncability in ('New Tuple', 'Duplicate')
  ON CONFLICT
	DO NOTHING
;

\echo clearing finished active jobs from pddocument_pending
DELETE FROM pdfbox2.pddocument_pending paj
  USING
  	merge_pddocument mp
  WHERE
  	paj.blob = mp.blob
	and
	mp.syncability  in (
		'New Tuple',
		'Duplicate'
	)
;
