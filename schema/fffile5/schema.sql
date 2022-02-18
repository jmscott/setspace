/*
 *  Synopsis:
 *	Schema for the file type guesser "Find Free File Command", version 5
 *  See:
 *	http://www.darwinsys.com/file/
 *  Note:
 *	Investigate "file" option "--uncompress".
 #
 *	Replace table fffile5.fault with fffile5.fault_process similar to
 *	pdfbox.fault_process.
 */

\set ON_ERROR_STOP on
SET search_path TO fffile5,public;

BEGIN;

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
CREATE INDEX file_blob ON file USING hash(blob);

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
CREATE INDEX file_mime_type_blob ON file_mime_type USING hash(blob);

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
CREATE INDEX file_mime_encoding_blob ON file_mime_encoding USING hash(blob);

/*
 *  Track very rare failures in various file commands defined in flowd.
 */
DROP TABLE IF EXISTS fault;
CREATE TABLE fault
(
	blob		udig,
	command_name	text CHECK (
				command_name in (
					'file',
					'file_mime_encoding',
					'file_mime_type'
				)
			),
	exit_status	smallint CHECK (
				exit_status > 0
				and
				exit_status <= 255
			) NOT NULL,
	insert_time	timestamptz
				DEFAULT now()
				NOT NULL,
	PRIMARY KEY	(blob, command_name)
);
COMMENT ON TABLE fault IS
  'Track failures in file commands'
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

COMMIT;
