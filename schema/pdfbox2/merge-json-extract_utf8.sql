/*
 *  Synopsis:
 *	merge jsonorg putPDDocument json objects into pdfbox2.pddocument tables
 *  Usage:
 *	psql -f merge-json-extract_utf8.sql --variable=since="'-1 day'"
 */

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
  	jsonorg.jsonb_255
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
  	syncability = 'JSON UTF8 Tuple Exists'
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

\echo merging New Tuples into table pdfbox2.extract_utf8
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
