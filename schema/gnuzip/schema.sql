/*
 *  Synopsis:
 *	SQL schema for gnu gzip command.	
 */

\set ON_ERROR_STOP

BEGIN;

DROP SCHEMA IF EXISTS gnuzip CASCADE;
CREATE SCHEMA gnuzip;

SET search_path to gnuzip,public;

CREATE TABLE gunzip_test_quiet
(
	blob		udig
				REFERENCES setcore.service
				PRIMARY KEY,
	exit_status	setcore.uni_xstatus
				NOT NULL
);

COMMIT;
