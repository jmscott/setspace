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
  'Exit status of gnu command "gunzip --test --quiet"'
;

/*
 *  Output of gunzip (v1.10) --list --name
 *	
 */
CREATE TABLE gunzip_uncompressed_name
(
	blob		udig
				REFERENCES gunzip_test
				PRIMARY KEY,
	name		text NOT NULL
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
DROP TABLE IF EXISTS gnuzip_uncompress_byte_count;
CREATE TABLE gnuzip_uncompress_byte_count
(
	blob		udig
				REFERENCES gunzip_test
				PRIMARY KEY,
	byte_count	bigint
);

COMMIT;
