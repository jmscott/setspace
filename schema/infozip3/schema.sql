/*
 *  Synopsis:
 *	SQL schema for famous infozip3 program, aka zip on most unixes
 *  See:
 *	http://infozip.sourceforge.net
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
				NOT NULL,
	stdio_255	bytea CHECK (
				length(stdio_255) <= 255
			) NOT NULL
);
COMMENT ON TABLE unzip_test IS
  'The exit status of invocation of unzip -qt on the blob'
;
COMMENT ON COLUMN unzip_test.stdio_255 IS
  'Up to the first 256 chars of stderr/out on unzip -qt <blob>'
;

--  Note: view rummy always returns empty, for now
DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'::udig
    WHERE
    	false
;

COMMENT ON VIEW rummy IS
  'Known unknown blobs in schema infozip3'
;

END;
