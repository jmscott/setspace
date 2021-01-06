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
				ON DELETE CASCADE
				PRIMARY KEY,
	exit_status	setcore.uni_xstatus
				NOT NULL
);
COMMENT ON TABLE gunzip_test_quiet IS
  'Exit status of gnu command "gunzip --test --quiet"'
;

CREATE TABLE gunzip_list_verbose
(
	blob		udig
				REFERENCES setcore.service
				PRIMARY KEY,
	method		text CHECK (
				length(method) > 0
				AND
				length(method) < 32
			) NOT NULL,
	crc		text CHECK (
				--  Note: not sure about field length
				crc ~ '^[0-9a-f]{1,8}$'
			) NOT NULL,
	date		text CHECK (
				length(date) > 0
				AND
				length(date) < 32
			) NOT NULL,
	time		text CHECK (
				length(date) > 0
				AND
				length(date) < 32
			) NOT NULL,

	--  Note: sometime uncompressed > compressed, for random data
	compressed	bigint CHECK (
				compressed >= 0
			) NOT NULL,
	uncompressed	bigint CHECK (
				uncompressed >= 0
			),

	ratio		real NOT NULL,
	uncompressed_name text CHECK (
				length(uncompressed_name) < 256
			) NOT NULL
);
COMMENT ON TABLE gunzip_list_verbose IS
  'Attributes of command gnu comand "gunzip --list --verbose"'
;

COMMIT;
