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

/*
 *  Synopsis:
 *	Find recent blobs in service but not in a table in fffile5.*
 *  Note:
 *	Querying setcore.service is incorrect.  Onstead, need to find all
 *	blobs defined in at least one fffile5.* table but not in all fffile5.*
 *	tables.
 */
DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
	s.blob
    FROM
  	setcore.service s
	  LEFT OUTER JOIN file f ON (f.blob = s.blob)
	  LEFT OUTER JOIN file_mime_type ft ON (ft.blob = s.blob)
	  LEFT OUTER JOIN file_mime_encoding fe ON (fe.blob = s.blob)
	  LEFT OUTER JOIN fault flt ON (flt.blob = s.blob)
    WHERE
  	(
		f.blob IS NULL
		OR
		ft.blob IS NULL
		OR
		fe.blob IS NULL
	)
	AND
	flt.blob IS NULL
;
COMMENT ON VIEW rummy IS
  'All blobs with undiscover attributes in schema fffile5'
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

COMMIT TRANSACTION;
