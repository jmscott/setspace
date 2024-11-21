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

/*
 *  Output of 'file --brief' command on blob.
 */
DROP TABLE IF EXISTS file CASCADE;
CREATE TABLE file
(
	blob		udig
				REFERENCES setcore.service(blob)
				ON DELETE CASCADE
				PRIMARY KEY,

	--  null indicates file produces non-utf8 output and exit status == 0
	--  trailing new-lines have been trimmed
	file_type	text
);
COMMENT ON TABLE file IS
  'Output of file --brief command on blob'
;
CREATE INDEX file_blob_idx ON file USING hash(blob);
CREATE INDEX file_type_idx ON file(file_type);

/*
 *  Output of 'file --mime-type --brief' command on blob.
 */
DROP TABLE IF EXISTS file_mime_type CASCADE;
CREATE TABLE file_mime_type
(
	blob		udig
				REFERENCES setcore.service(blob)
				ON DELETE CASCADE
				PRIMARY KEY,
	--  null indicates file produces non-utf8 output and exit status == 0
	mime_type	text
);
COMMENT ON TABLE file_mime_type IS
  'Output of file --mime-type --brief command on blob'
;
CREATE INDEX file_mime_type_blob_idx ON file_mime_type USING hash(blob);
CREATE INDEX file_mime_type_idx ON file_mime_type(mime_type);

/*
 *  Output of 'file --mime-encoding --brief' command on blob.
 */
DROP TABLE IF EXISTS file_mime_encoding CASCADE;
CREATE TABLE file_mime_encoding
(
	blob		udig
				REFERENCES setcore.service(blob)
				ON DELETE CASCADE
				PRIMARY KEY,
	--  null indicates file produces non-utf8 output and exit status == 0
	mime_encoding	text
);
COMMENT ON TABLE file_mime_encoding IS
  'Output of file --mime-encoding --brief command on blob'
;
CREATE INDEX file_mime_encoding_blob_idx ON file_mime_encoding USING hash(blob);
CREATE INDEX file_mime_encoding_idx ON file_mime_encoding(mime_encoding);

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

DROP MATERIALIZED VIEW IF EXISTS file_stat CASCADE;
CREATE MATERIALIZED VIEW file_stat (
	file_type,
	blob_count
) AS
  SELECT
  	file_type,
	count(*)
    FROM
    	file
    GROUP BY
    	file_type
  WITH DATA
;
COMMENT ON MATERIALIZED VIEW file_stat IS
  'Statistics on blob counts per file type'
;
CREATE UNIQUE INDEX file_stat_ft
  ON file_stat (file_type)
;
ANALYZE file_stat;

DROP MATERIALIZED VIEW IF EXISTS file_mime_type_stat CASCADE;
CREATE MATERIALIZED VIEW file_mime_type_stat (
	mime_type,
	blob_count
) AS
  SELECT
  	mime_type,
	count(*)
    FROM
    	file_mime_type
    GROUP BY
    	mime_type
  WITH DATA
;
COMMENT ON MATERIALIZED VIEW file_mime_type_stat IS
  'Statistics on blob counts per mime type'
;
CREATE UNIQUE INDEX file_mime_type_stat_ft
  ON file_mime_type_stat (mime_type)
;
ANALYZE file_mime_type_stat;

DROP MATERIALIZED VIEW IF EXISTS file_mime_encoding_stat CASCADE;
CREATE MATERIALIZED VIEW file_mime_encoding_stat (
	mime_encoding,
	blob_count
) AS
  SELECT
  	mime_encoding,
	count(*)
    FROM
    	file_mime_encoding
    GROUP BY
    	mime_encoding
  WITH DATA
;
COMMENT ON MATERIALIZED VIEW file_mime_encoding_stat IS
  'Statistics on blob counts per mime type'
;
CREATE UNIQUE INDEX file_mime_encoding_stat_ft
  ON file_mime_encoding_stat (mime_encoding)
;
ANALYZE file_mime_encoding_stat;

DROP FUNCTION IF EXISTS refresh_stat();
CREATE OR REPLACE FUNCTION refresh_stat() RETURNS void
  AS $$
  BEGIN
  	REFRESH MATERIALIZED VIEW CONCURRENTLY file_stat;
  	REFRESH MATERIALIZED VIEW CONCURRENTLY file_mime_type_stat;
  	REFRESH MATERIALIZED VIEW CONCURRENTLY file_mime_encoding_stat;

	ANALYZE file_stat;
	ANALYZE file_mime_type_stat;
	ANALYZE file_mime_encoding_stat;
  END $$
  LANGUAGE plpgsql
;
COMMENT ON FUNCTION refresh_stat IS
  'Concurrently Refresh and Analyze All Materialied *_stat Views in fffile5'
;

DROP VIEW IF EXISTS service CASCADE;
CREATE VIEW service AS
  SELECT
  	f.blob
    FROM
    	file f
	  JOIN file_mime_type fm ON (fm.blob = f.blob)
	  JOIN file_mime_encoding fe ON (fe.blob = f.blob)
;
COMMENT ON VIEW service IS
  'Blobs with file, mime type and encoding known' 
;

DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  WITH all_blob AS (
    SELECT
    	blob
      FROM
      	file
    UNION SELECT
	blob
      FROM
  	file_mime_type
    UNION SELECT
	blob
      FROM
  	file_mime_encoding
  ) SELECT
  	a.blob
      FROM
      	all_blob a
      WHERE
      	NOT EXISTS (
	  SELECT
	  	srv.blob
	    FROM
	    	service srv
	    WHERE
	    	srv.blob = a.blob
	)
;

COMMENT ON VIEW rummy IS
  'All blobs with relations not discovered'
;

COMMENT ON VIEW rummy IS
  'All blobs with undiscover attributes in schema fffile5'
;

DROP VIEW IF EXISTS detail CASCADE;
CREATE VIEW detail AS
  SELECT
  	srv.blob,
	f.file_type,
	mt.mime_type,
	me.mime_encoding
    FROM
    	service srv
	  JOIN file f ON (f.blob = srv.blob)
	  JOIN file_mime_type mt ON (mt.blob = srv.blob)
	  JOIN file_mime_encoding me ON (me.blob = srv.blob)
;
COMMENT ON VIEW detail IS 'Details for blobs in service' ;

COMMIT TRANSACTION;
