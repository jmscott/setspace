/*
 *  Synopsis:
 *	SQL schema for famous infozip3 program, aka zip on most unixes
 */

\set ON_ERROR_STOP 1

SET search_path TO infozip3,public;

BEGIN;

DROP SCHEMA IF EXISTS infozip3 CASCADE;
CREATE SCHEMA infozip3;
COMMENT ON SCHEMA infozip3 IS
  'Famous infozip3 program, a.k.a. zip on most unixes'
;

DROP TABLE IF EXISTS unzip_test;
CREATE TABLE unzip_test
(
	blob		udig
				REFERENCES setcore.service
				PRIMARY KEY,
	exit_status	setcore.uni_xstatus
				NOT NULL
);

END
