/*
 *  Synopsis:
 *	SQL schema for gnu gzip command.	
 *  Note:
 *	Need to add test that exist code == 0 for foreign key reference
 *	in various subtables.  Can PG subtables have qualfiers?
 *
 *	Since gzip v1 is 32bit, the uncompressed file size is not reliable.
 */

\set ON_ERROR_STOP

BEGIN;

DROP SCHEMA IF EXISTS gnuzip CASCADE;
CREATE SCHEMA gnuzip;

SET search_path to gnuzip,public;

DROP TABLE IF EXISTS gunzip_test;
CREATE TABLE gunzip_test
(
	blob		udig
				REFERENCES setcore.service
				ON DELETE CASCADE
				PRIMARY KEY,
	exit_status	setcore.uni_xstatus
				NOT NULL
);
COMMENT ON TABLE gunzip_test IS
  'Exit status of gnu command "gunzip --test"'
;

/*
 *  Integrity tests need to insure exit_status == 0
 *  for child tables.  Perhaps a inherited table is better
 *  approach.
 */
DROP FUNCTION IF EXISTS gunzip_test_exit_status(udig)
  CASCADE
; 
CREATE FUNCTION gunzip_test_exit_status(blob udig)
  RETURNS setcore.uni_xstatus
  AS $$
  	SELECT
		exit_status
	  FROM
	  	gnuzip.gunzip_test
	  WHERE
	  	blob = $1
  $$ LANGUAGE SQL
; 
COMMENT ON FUNCTION gunzip_test_exit_status(udig) IS
  'Fetch the exit status in table gunzip_test'
;

/*
 *  Output of gunzip (v1.10) --list --name
 *	
 */
DROP TABLE IF EXISTS gunzip_uncompressed_name;
CREATE TABLE gunzip_uncompressed_name
(
	blob		udig
				REFERENCES gunzip_test
				ON DELETE CASCADE
				PRIMARY KEY,
	name		text NOT NULL,

	CONSTRAINT exit_status_0 CHECK (
		gnuzip.gunzip_test_exit_status(blob) = 0
	)
);
COMMENT ON TABLE gunzip_uncompressed_name IS
  'Uncompressed file name extracted from gunzip --list --name'
;

/*
 *  Reliable size of uncompressed file.
 *
 *  Note:
 *	32bit file sizes make gunzip unreliable.
 */
DROP TABLE IF EXISTS gnuzip_uncompressed_byte_count;
CREATE TABLE gnuzip_uncompressed_byte_count
(
	blob		udig
				REFERENCES gunzip_test
				ON DELETE CASCADE
				PRIMARY KEY,
	byte_count	bigint,

	CONSTRAINT exit_status_0 CHECK (
		gnuzip.gunzip_test_exit_status(blob) = 0
	)
);
COMMENT ON TABLE gnuzip_uncompressed_byte_count IS
  'Correct, uncompressed file size calculated "gunzip --stdout | setcore/byte-count'
;

COMMIT;
