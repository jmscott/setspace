/*
 *  Synopsis:
 *	merge jsonorg pdfbox2.setspace.com objects into pdfbox2.* tables
 *  Usage:
 *	psql -f merge-json.sql --variable=since="'-1 day'"
 */

\echo merging all blobs since :since

\timing on
\set ON_ERROR_STOP on

CREATE TEMP TABLE merge_utf8 AS
/*
 *  Merge jsonorg.jsonb_255{pdfbox.setspace.com->extract_utf8} into the table
 *  pdfbox2.extract_utf8.
 */
WITH find_utf8 AS (
  SELECT
  	blob AS jblob,
  	doc->'pdfbox.setspace.com'->'extract_utf8' AS doc
  FROM
  	jsonb_255
	  NATURAL JOIN setspace.service s
  WHERE
  	doc @> '{
	    "pdfbox.setspace.com": {
	      "extract_utf8": {}
	    }
	}'
	AND
	s.discover_time > now() + :since
),
  /*
   *  Extract UTF8 from json.
   */
  x_utf8 AS (
	SELECT
		jblob,
		blob,
		CASE
		  WHEN
		  	utf8_blob = 'null'
		  THEN
		  	null::udig
		  ELSE
		  	utf8_blob::udig
		END AS "utf8_blob",
		exit_status,

		/*
		 *  stderr_blob appears to be treated both as a string 'null'
		 *  or as a true null, depending upon the context.
		 */
		CASE
		  WHEN
		  	stderr_blob = 'null'
		  THEN
		  	null::udig
		  ELSE
		  	stderr_blob::udig
		END AS "stderr_blob"
	  from
		find_utf8,
		jsonb_to_record(doc) AS x(
			blob udig,
			utf8_blob text,
			exit_status smallint,
			stderr_blob text
		)
)
SELECT
	*,
	'New Tuple'::text AS "syncability"
  FROM
  	x_utf8
;

\echo indexing merge_utf8(blob)
CREATE index merge_utf8_idx_utf8 on merge_utf8(blob);

\echo indexing merge_utf8(blob)
CREATE unique index merge_utf8_idx_json on merge_utf8(jblob);

\echo indexing merge_utf8(syncability)
CREATE index merge_utf8_idx_sync on merge_utf8(syncability);

\echo analyze merge_utf8
ANALYZE merge_utf8;

\echo tagging blobs already merged
UPDATE merge_utf8 m1
  SET
  	syncability = 'UTF8 Tuple Exists'
  WHERE
  	EXISTS (
	  SELECT
	  	m2.blob
	  FROM
	  	merge_utf8 m2
	  WHERE
	  	m2.blob = m1.blob
		AND
		m2.jblob != m1.jblob
	)
	AND
	m1.syncability = 'New Tuple'
;

\echo reanalyze merge_utf8 after UTF8 Tuple Exists
VACUUM ANALYZE merge_utf8;

\echo tagging blobs with no primary key reference in pdfbox2.pddocument
UPDATE merge_utf8 m
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
;
\echo reanalyze merge_utf8 after No Primary Key in pdfbox2.pddocument
VACUUM ANALYZE merge_utf8;

\echo tagging duplicate blobs in different json runs not yet merged
UPDATE merge_utf8 m1
  SET
  	syncability = 'Duplicate'
  WHERE
  	EXISTS (
	  SELECT
	  	m2.blob
	  FROM
	  	merge_utf8 m2
	  WHERE
	  	m2.blob = m1.blob
		AND
		m2.jblob != m1.jblob
	)
	AND
	m1.syncability = 'New Tuple'
;
\echo reanalyze merge_utf8 after Duplcate
VACUUM ANALYZE merge_utf8;

\echo summarizing merge set
SELECT
	syncability,
	count(*) AS "JSON Tuple Count"
  FROM
  	merge_utf8
  GROUP BY
  	1
  ORDER BY
  	syncability = 'New Tuple' desc,
	"JSON Tuple Count" desc
;
