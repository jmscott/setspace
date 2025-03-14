/*
 *  Synopsis:
 *	Schema for the file type guesser "Find Free File Command", version 5
 *  See:
 *	http://www.darwinsys.com/file/
 *  Note:
 *	Investigate "file" option "--uncompress".
 */

\set ON_ERROR_STOP on
SET search_path TO fffile5,public;

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS fffile5 CASCADE;
CREATE SCHEMA fffile5;
COMMENT ON SCHEMA fffile5 IS
  'Text and metadata extracted by "Find Free File Command", version 5'
;

DROP DOMAIN IF EXISTS fffile5.udig;
CREATE DOMAIN udig AS setcore.udig;

DROP DOMAIN IF EXISTS type1023 CASCADE;
CREATE DOMAIN type1023 AS text
  CHECK (
  	value ~ '[[:graph:]]'
	AND
	length(value) < 1024
  )
;

DROP TABLE IF EXISTS blob CASCADE;
CREATE TABLE blob
(
	blob		udig
				REFERENCES setcore.blob
				PRIMARY KEY,
	discover_time	setcore.inception
				NOT NULL
);
CREATE INDEX idx_blob ON blob USING hash(blob);
CREATE INDEX idx_blob_discover_time ON blob(discover_time);
CLUSTER blob USING idx_blob_discover_time;

/*
 *  Output of 'file --brief' command on blob.
 */
DROP TABLE IF EXISTS file_brief CASCADE;
CREATE TABLE file_brief
(
	blob		udig
				REFERENCES blob
				ON DELETE CASCADE
				PRIMARY KEY,

	file_type	type1023 NOT NULL
);
COMMENT ON TABLE file_brief IS
  'Output of file --brief command on blob'
;
CREATE INDEX idx_file_brief_blob ON file_brief USING hash(blob);
CREATE INDEX idx_file_brief_file_type ON file_brief(file_type);
CLUSTER file_brief USING idx_file_brief_file_type; 

/*
 *  Output of 'file --mime-type --brief' command on blob.
 */
DROP TABLE IF EXISTS file_mime_type_brief CASCADE;
CREATE TABLE file_mime_type_brief
(
	blob		udig
				REFERENCES blob
				ON DELETE CASCADE
				PRIMARY KEY,
	mime_type	type1023	NOT NULL
);
COMMENT ON TABLE file_mime_type_brief IS
  'Output of file --mime-type --brief command on blob'
;
CREATE INDEX idx_file_mime_type_brief_blob ON
	file_mime_type_brief USING hash(blob);
CREATE INDEX idx_file_mime_type_brief ON file_mime_type_brief(mime_type);
CLUSTER file_mime_type_brief USING idx_file_mime_type_brief;

/*
 *  Output of 'file --mime-encoding --brief' command on blob.
 */
DROP TABLE IF EXISTS file_mime_encoding_brief CASCADE;
CREATE TABLE file_mime_encoding_brief
(
	blob		udig
					REFERENCES blob
					ON DELETE CASCADE
					PRIMARY KEY,
	mime_encoding	type1023	NOT NULL
);
COMMENT ON TABLE file_mime_encoding_brief IS
  'Output of file --mime-encoding --brief command on blob'
;
CREATE INDEX idx_file_mime_encoding_brief_blob
  ON file_mime_encoding_brief USING hash(blob)
; 
CREATE INDEX idx_file_mime_encoding_brief_mime_encoding
  ON file_mime_encoding_brief(mime_encoding);
CLUSTER file_mime_encoding_brief
  USING
  	idx_file_mime_encoding_brief_mime_encoding
;

/*
 *  Track very rare failures in various file commands defined in flowd.
 */
DROP VIEW IF EXISTS fault CASCADE;
CREATE VIEW fault AS
  SELECT
  	DISTINCT blob
    FROM
    	setops.flowd_call_fault flt
    WHERE
    	flt.schema_name = 'fffile5'
;
COMMENT ON VIEW fault IS
  'Blobs for which the "file" commands failed (rare)'
;

DROP MATERIALIZED VIEW IF EXISTS file_brief_stat CASCADE;
CREATE MATERIALIZED VIEW file_brief_stat (
	file_type,
	blob_count
) AS
  SELECT
  	file_type,
	count(*)
    FROM
    	file_brief
    GROUP BY
    	file_type
  WITH DATA
;
COMMENT ON MATERIALIZED VIEW file_brief_stat IS
  'Statistics on blob counts per file type'
;
CREATE UNIQUE INDEX idx_file_stat_ft
  ON file_brief_stat (file_type)
;
ANALYZE file_brief_stat;

DROP MATERIALIZED VIEW IF EXISTS file_mime_type_brief_stat CASCADE;
CREATE MATERIALIZED VIEW file_mime_type_brief_stat (
	mime_type,
	blob_count
) AS
  SELECT
  	mime_type,
	count(*)
    FROM
    	file_mime_type_brief
    GROUP BY
    	mime_type
  WITH DATA
;
COMMENT ON MATERIALIZED VIEW file_mime_type_brief_stat IS
  'Statistics on blob counts per mime type'
;
CREATE UNIQUE INDEX idx_file_mime_type_brief_stat_ft
  ON file_mime_type_brief_stat (mime_type)
;
ANALYZE file_mime_type_brief_stat;

DROP MATERIALIZED VIEW IF EXISTS file_mime_encoding_brief_stat CASCADE;
CREATE MATERIALIZED VIEW file_mime_encoding_brief_stat (
	mime_encoding,
	blob_count
) AS
  SELECT
  	mime_encoding,
	count(*)
    FROM
    	file_mime_encoding_brief
    GROUP BY
    	mime_encoding
  WITH DATA
;
COMMENT ON MATERIALIZED VIEW file_mime_encoding_brief_stat IS
  'Statistics on blob counts per mime type'
;
CREATE UNIQUE INDEX idx_file_mime_encoding_brief_stat_ft
  ON file_mime_encoding_brief_stat (mime_encoding)
;
ANALYZE file_mime_encoding_brief_stat;

DROP FUNCTION IF EXISTS refresh_stat();
CREATE OR REPLACE FUNCTION refresh_stat() RETURNS void
  AS $$
  BEGIN
  	REFRESH MATERIALIZED VIEW CONCURRENTLY file_brief_stat;
  	REFRESH MATERIALIZED VIEW CONCURRENTLY file_mime_type_brief_stat;
  	REFRESH MATERIALIZED VIEW CONCURRENTLY file_mime_encoding_brief_stat;

	ANALYZE file_brief_stat;
	ANALYZE file_mime_type_brief_stat;
	ANALYZE file_mime_encoding_brief_stat;
  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION refresh_stat IS
  'Concurrently Refresh and Analyze All Materialied *_stat Views in fffile5'
;

DROP VIEW IF EXISTS service CASCADE;
CREATE VIEW service AS
  SELECT
  	b.blob
    FROM
    	blob b
	  JOIN file_brief f ON (f.blob = b.blob)
	  JOIN file_mime_type_brief fm ON (fm.blob = f.blob)
	  JOIN file_mime_encoding_brief fe ON (fe.blob = f.blob)
;
COMMENT ON VIEW service IS
  'Blobs with file, mime type and encoding known' 
;

DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
  	b.blob
    FROM
    	blob b
	  NATURAL LEFT OUTER JOIN file_brief fb
	  NATURAL LEFT JOIN file_mime_type_brief fm
	  NATURAL LEFT JOIN file_mime_encoding_brief fe
    WHERE
    	fb.blob IS NULL
	OR
	fm.blob IS NULL
	OR
	fe.blob IS NULL
;

COMMENT ON VIEW rummy IS
  'All blobs with undiscovered facts, not in service or fault'
;

COMMIT TRANSACTION;
