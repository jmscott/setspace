/*
 *  Synopsis:
 *	merge jsonorg pdfbox2.setspace.com objects into pdfbox2.* tables
 *  Usage:
 *	psql -f merge-json.sql --variable=since="'-1 day'"
 *  Note:
 *	Change :since to be a full blown postgres timestamp.
 */

\echo merging all blobs since :since

\timing on
\set ON_ERROR_STOP on

CREATE TEMP TABLE merge_pddocument AS
WITH find_pddocument AS (
  SELECT
  	blob AS jblob,
  	doc->'pdfbox2.setspace.com'->'putPDDocument' AS doc
  FROM
  	jsonb_255
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
	is_encrypted
    FROM
	find_pddocument,
	  LATERAL jsonb_to_record(doc) AS j2r(
		blob udig,
		exit_status smallint,
		number_of_pages int,
		document_id bigint,
		version float,
		is_all_security_to_be_removed bool,
		is_encrypted bool
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
  	syncability = 'PDDocument Tuple Exists'
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

CREATE TEMP TABLE merge_extract_utf8 AS
/*
 *  Merge jsonorg.jsonb_255{pdfbox2.setspace.com->extract_utf8} into the table
 *  pdfbox2.extract_utf8.
 */
WITH find_utf8 AS (
  SELECT
  	blob AS jblob,
  	doc->'pdfbox2.setspace.com'->'extract_utf8' AS doc
  FROM
  	jsonb_255
	  NATURAL JOIN setspace.service s
  WHERE
  	doc @> '{
	    "pdfbox2.setspace.com": {
	      "extract_utf8": {}
	    }
	}'
	AND
	s.discover_time > now() + :since
),
  /*
   *  Convert json row to database tuple
   */
  json2row AS (
    SELECT
	jblob,
	blob,
	utf8_blob,
	exit_status,
	stderr_blob
    from
	find_utf8,
	jsonb_to_record(doc) AS x(
		blob udig,
		utf8_blob udig,
		exit_status smallint,
		stderr_blob udig
	)
)
SELECT
	*,
	'New Tuple'::text AS "syncability"
  FROM
  	json2row
;

\echo indexing merge_extract_utf8(blob)
CREATE index merge_utf8_idx_utf8 on merge_extract_utf8(blob);

\echo indexing merge_extract_utf8(jblob)
CREATE unique index merge_utf8_idx_json on merge_extract_utf8(jblob);

\echo indexing merge_extract_utf8(syncability)
CREATE index merge_utf8_idx_sync on merge_extract_utf8(syncability);

\echo analyze merge_extract_utf8
ANALYZE merge_extract_utf8;

\echo tagging blobs already merged
UPDATE merge_extract_utf8 m1
  SET
  	syncability = 'UTF8 Tuple Exists'
  WHERE
  	EXISTS (
	  SELECT
	  	m2.blob
	  FROM
	  	pdfbox2.extract_utf8 m2
	  WHERE
	  	m2.blob = m1.blob
	)
	AND
	m1.syncability = 'New Tuple'
;

\echo reanalyze merge_extract_utf8 after UTF8 Tuple Exists
VACUUM ANALYZE merge_extract_utf8;

\echo tagging blobs with no primary key reference in pdfbox2.pddocument
UPDATE merge_extract_utf8 m
  set
  	syncability = 'No Primary Key in pdfbox2.pddocument'
  where
  	NOT EXISTS (
	  SELECT
	  	p.blob
	    FROM
	    	pdfbox2.pddocument p
	    WHERE
	    	p.blob = m.blob
	)
	AND
	m.syncability = 'New Tuple'
;
\echo reanalyze merge_extract_utf8 after No Primary Key in pdfbox2.pddocument
VACUUM ANALYZE merge_extract_utf8;

\echo tagging duplicate blobs in different json runs not yet merged
UPDATE merge_extract_utf8 m1
  SET
  	syncability = 'Duplicate'
  WHERE
  	EXISTS (
	  SELECT
	  	m2.blob
	  FROM
	  	merge_extract_utf8 m2
	  WHERE
	  	m2.blob = m1.blob
		AND
		m2.jblob != m1.jblob
	)
	AND
	m1.syncability = 'New Tuple'
;
\echo reanalyze merge_extract_utf8 after Duplicate
VACUUM ANALYZE merge_extract_utf8;

\echo summarizing merge extract_utf8 set since :since
SELECT
	syncability,
	count(*) AS "JSON Tuple Count"
  FROM
  	merge_extract_utf8
  GROUP BY
  	1
  ORDER BY
  	syncability = 'New Tuple' desc,
	"JSON Tuple Count" desc
;

\echo mergining New Tuples into table pdfbox2.extract_utf8
INSERT INTO pdfbox2.extract_utf8 (
	blob,
	exit_status,
	utf8_blob,
	stderr_blob
) SELECT
	blob,
	exit_status,
	utf8_blob,
	stderr_blob
    FROM
    	merge_extract_utf8
    WHERE
    	syncability in ('New Tuple', 'Duplicate')
  ON CONFLICT
  	DO NOTHING
;

\echo summarize new tuples added to tables pddocument and extract_utf8
select
	(select
		count(distinct pd.blob)
	  from
	  	merge_pddocument pd
	  where
	  	pd.syncability in ('New Tuple', 'Duplicate')

	) as "New PDDocument Blob Count",

	(select
		count(distinct u8.blob)
	  from
	  	merge_extract_utf8 u8
	  where
	  	u8.syncability in ('New Tuple', 'Duplicate')

	) as "New PDF UTF8 Blob Count"
;
