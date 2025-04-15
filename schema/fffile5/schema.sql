/*
 *  Synopsis:
 *	Schema for the file type guesser "Find Free File Command", version 5
 *  See:
 *	http://www.darwinsys.com/file/
 *  Note:
 *	Investigate "file" option "--uncompress".
 */

\set ON_ERROR_STOP on
SET search_path TO fffile5,setspace,public;

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS fffile5 CASCADE;
CREATE SCHEMA fffile5;
COMMENT ON SCHEMA fffile5 IS
  'Text and metadata extracted by "Find Free File Command", version 5'
;

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
				PRIMARY KEY,
	discover_time	inception
				DEFAULT now()
				NOT NULL
);
CREATE INDEX idx_blob_hash ON blob USING hash(blob);
CREATE INDEX idx_blob_discover_time ON blob(discover_time);
CLUSTER blob USING idx_blob_discover_time;

/*
 *  Output of 'file --brief' command on blob.
 */
DROP TABLE IF EXISTS file CASCADE;
CREATE TABLE file
(
	blob		udig
				REFERENCES blob
				ON DELETE CASCADE
				PRIMARY KEY,

	file_type	type1023 NOT NULL
);
COMMENT ON TABLE file IS
  'Output of file --brief command on blob'
;
CREATE INDEX idx_file_hash ON file USING hash(blob);
CREATE INDEX idx_file_type ON file(file_type);
CLUSTER file USING idx_file_type; 

/*
 *  Output of 'file --mime-type' command on blob.
 */
DROP TABLE IF EXISTS file_mime_type CASCADE;
CREATE TABLE file_mime_type
(
	blob		udig
				REFERENCES blob
				ON DELETE CASCADE
				PRIMARY KEY,
	mime_type	type1023	NOT NULL
);
COMMENT ON TABLE file_mime_type IS
  'Output of file --mime-type --brief command on blob'
;
CREATE INDEX idx_file_mime_type_hash ON
	file_mime_type USING hash(blob);
CREATE INDEX idx_file_mime_type ON file_mime_type(mime_type);
CLUSTER file_mime_type USING idx_file_mime_type;

/*
 *  Output of 'file --mime-encoding --brief' command on blob.
 */
DROP TABLE IF EXISTS file_mime_encoding CASCADE;
CREATE TABLE file_mime_encoding
(
	blob		udig
					REFERENCES blob
					ON DELETE CASCADE
					PRIMARY KEY,
	mime_encoding	type1023	NOT NULL
);
COMMENT ON TABLE file_mime_encoding IS
  'Output of file --mime-encoding --brief command on blob'
;
CREATE INDEX idx_file_mime_encoding_hash
  ON file_mime_encoding USING hash(blob)
; 
CREATE INDEX idx_file_mime_encoding_mime_encoding
  ON file_mime_encoding(mime_encoding);
CLUSTER file_mime_encoding
  USING
  	idx_file_mime_encoding_mime_encoding
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
CREATE UNIQUE INDEX idx_file_stat_ft
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
CREATE UNIQUE INDEX idx_file_mime_type_stat_ft
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
CREATE UNIQUE INDEX idx_file_mime_encoding_stat_ft
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
  	b.blob,
	b.discover_time
    FROM
    	blob b
	  JOIN file f ON (f.blob = b.blob)
	  JOIN file_mime_type fm ON (fm.blob = f.blob)
	  JOIN file_mime_encoding fe ON (fe.blob = f.blob)
;
COMMENT ON VIEW service IS
  'Blobs with file, mime type and encoding known' 
;

DROP VIEW IF EXISTS rummy CASCADE;
/*
 *  Find all blobs in an unknown state
 */
CREATE VIEW rummy AS
  SELECT
  	b.blob
    FROM
    	blob b
	  NATURAL LEFT OUTER JOIN file f
	  NATURAL LEFT OUTER JOIN file_mime_type ft
	  NATURAL LEFT OUTER JOIN file_mime_encoding fe
    WHERE
    	(
		f.blob IS NULL
		AND
		--  not in fault for command upsert-file
		NOT EXISTS (
		  SELECT
		  	true
		    FROM
		    	setops.flowd_call_fault flt
		    WHERE
		    	flt.schema_name = 'fffile5'
			AND
			flt.command_name = 'upsert_file'
			AND
			flt.blob = b.blob
		)
	)
	OR
    	(
		ft.blob IS NULL
		AND
		--  not in fault for command upsert-file_mime_type
		NOT EXISTS (
		  SELECT
		  	true
		    FROM
		    	setops.flowd_call_fault flt
		    WHERE
		    	flt.schema_name = 'fffile5'
			AND
			flt.command_name = 'upsert_file_mime_type'
			AND
			flt.blob = b.blob
		)
	)
	OR
    	(
		fe.blob IS NULL
		AND
		--  not in fault for command upsert-file_mime_eencoding
		NOT EXISTS (
		  SELECT
		  	true
		    FROM
		    	setops.flowd_call_fault flt
		    WHERE
		    	flt.schema_name = 'fffile5'
			AND
			flt.command_name = 'upsert_file_mime_encoding'
			AND
			flt.blob = b.blob
		)
	)
;
COMMENT ON VIEW rummy IS
  'All blobs with undiscovered facts, not in service or fault'
;

REVOKE UPDATE ON TABLE
	file,
	file_mime_type,
	file_mime_encoding
  FROM
  	PUBLIC
;

COMMIT TRANSACTION;
