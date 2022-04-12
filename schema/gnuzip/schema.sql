/*
 *  Synopsis:
 *	SQL schema for gnu gzip command, with table for broken 64bit sizes.
 *  Note:
 *	Since gzip v1 is 32bit, the uncompressed file size is not reliable,
 *	hence we calculate size with setcore/sbin/byte_count.
 */

\set ON_ERROR_STOP 1

BEGIN;

DROP SCHEMA IF EXISTS gnuzip CASCADE;
CREATE SCHEMA gnuzip;

SET search_path to gnuzip,public;

DROP TABLE IF EXISTS gunzip_test_quiet;
CREATE TABLE gunzip_test_quiet
(
	blob		udig
				REFERENCES setcore.service
				ON DELETE CASCADE
				PRIMARY KEY,
	exit_status	setcore.uni_xstatus
				NOT NULL
);
COMMENT ON TABLE gunzip_test_quiet IS
  'Exit status of gnu command "gunzip --test"'
;

/*
 *  Integrity tests to insure exit_status == 0
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
	  	gnuzip.gunzip_test_quiet
	  WHERE
	  	blob = $1
  $$ LANGUAGE SQL
; 
COMMENT ON FUNCTION gunzip_test_exit_status(udig) IS
  'Fetch the exit status in table gunzip_test_quiet used by constraint'
;

/*
 *  File name extracted with gunzip (v1.10) --list --name
 */
DROP TABLE IF EXISTS gunzip_uncompressed_name;
CREATE TABLE gunzip_uncompressed_name
(
	blob		udig
				REFERENCES gunzip_test_quiet
				ON DELETE CASCADE
				PRIMARY KEY,
	name		bytea CHECK (
				length(name) < 256
			) NOT NULL,

	CONSTRAINT exit_status_0 CHECK (
		gnuzip.gunzip_test_exit_status(blob) = 0
	)
);
COMMENT ON TABLE gunzip_uncompressed_name IS
  'File name extracted with gunzip --list --name'
;

/*
 *  Reliable size of uncompressed file.
 *
 *  Note:
 *	32bit file sizes make gunzip unreliable.
 */
DROP TABLE IF EXISTS gunzip_uncompressed_byte_count;
CREATE TABLE gunzip_uncompressed_byte_count
(
	blob		udig
				REFERENCES gunzip_test_quiet
				ON DELETE CASCADE
				PRIMARY KEY,
	byte_count	bigint,

	CONSTRAINT exit_status_0 CHECK (
		gnuzip.gunzip_test_exit_status(blob) = 0
	)
);
COMMENT ON TABLE gunzip_uncompressed_byte_count IS
  'Correct, uncompressed file size calculated "gunzip --stdout | setcore/byte-count"'
;

/*
 *  Synopsis:
 *	Find recent blobs in service but not in a table in gnufile.*
 */
DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
	t.blob
    FROM
  	gnuzip.gunzip_test_quiet t
	  LEFT OUTER JOIN gnuzip.gunzip_uncompressed_name n
	    ON
	    	(n.blob = t.blob)
	  LEFT OUTER JOIN gnuzip.gunzip_uncompressed_byte_count bc
	    ON
	  	(bc.blob = t.blob)
    WHERE
  	t.exit_status = 0
	AND
	(
		n.blob IS NULL
		OR
		bc.blob IS NULL
	)
;
COMMENT ON VIEW rummy IS
  'blobs with undiscovered attributes in schema gnuzip'
;

COMMIT;
