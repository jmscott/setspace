/*
 *  Synopsis:
 *	Schema for the file type guesser "Find Free File Command", version 5
 *  See:
 *	http://www.darwinsys.com/file/
 */

\set ON_ERROR_STOP on

BEGIN;

DROP SCHEMA IF EXISTS fffile CASCADE;
CREATE SCHEMA fffile;
COMMENT ON SCHEMA fffile IS
  'Text and metadata extracted by "Find Free File Command", version 5'
;

/*
 *  Output of 'file --brief' command on blob.
 */
DROP TABLE IF EXISTS fffile.file CASCADE;
CREATE TABLE fffile.file
(
	blob		udig
				REFERENCES setspace.service(blob)
				ON DELETE CASCADE
				PRIMARY KEY,

	--  null indicates file produces non-utf8 output and exit status == 0
	--  trailing new-lines have been trimmed
	file_type	text
);
COMMENT ON TABLE fffile.file IS
  'Output of file --brief command on blob'
;

/*
 *  Output of 'file --mime-type --brief' command on blob.
 */
DROP TABLE IF EXISTS fffile.file_mime_type CASCADE;
CREATE TABLE fffile.file_mime_type
(
	blob		udig
				REFERENCES setspace.service(blob)
				ON DELETE CASCADE
				primary key,
	--  null indicates file produces non-utf8 output and exit status == 0
	mime_type	text
);
COMMENT ON TABLE fffile.file_mime_type IS
  'Output of file --mime-type --brief command on blob'
;

/*
 *  Output of 'file --mime-encoding --brief' command on blob.
 */
DROP TABLE IF EXISTS fffile.file_mime_encoding CASCADE;
CREATE TABLE fffile.file_mime_encoding
(
	blob		udig
				REFERENCES setspace.service(blob)
				ON DELETE CASCADE
				primary key,
	--  null indicates file produces non-utf8 output and exit status == 0
	mime_encoding	text
);
COMMENT ON TABLE fffile.file_mime_encoding IS
  'Output of file --mime-encoding --brief command on blob'
;

/*
 *  Track very rare failures in various file commands defined in flowd.
 */
DROP TABLE IF EXISTS fffile.fault;
CREATE TABLE fffile.fault
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
			),
	insert_time	timestamptz
				DEFAULT now()
				NOT NULL,
	PRIMARY KEY	(blob, command_name)
);
COMMENT ON TABLE fffile.fault IS
  'Track failures in file commands'
;

COMMIT;
