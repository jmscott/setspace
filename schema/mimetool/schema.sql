/*
 *  Synopsis:
 *	Index mime blobs using well known perl package MIME::Tools
 */

\set ON_ERROR_STOP 1

DROP SCHEMA IF EXISTS mimetool CASCADE;
CREATE SCHEMA mimetool;
COMMENT ON SCHEMA mimetool IS
  'SQL Schema indexing output of famous MIME::Tools package'
;

SET search_path TO mimetool,public;

BEGIN TRANSACTION;

DROP TABLE IF EXISTS parser;
CREATE TABLE parser (
	blob	udig
			PRIMARY KEY,
	parsed	bool
			NOT NULL
);
COMMENT ON TABLE parser IS
  'Status of output of perl MIME::Tool->parser' 
;

END TRANSACTION;
