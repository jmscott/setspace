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
	blob		udig
				PRIMARY KEY,
	parsed		bool
				NOT NULL,
	tags_count	bigint CHECK (
				tags_count >= 0
			),
	CONSTRAINT check_tags CHECK (
		(
			parsed IS TRUE
			AND
			tags_count IS NOT NULL
		) OR (
			parsed IS FALSE
			AND
			tags_count IS NULL
		)
	)
);
COMMENT ON TABLE parser IS
  'Status of output of perl MIME::Tool->parser()' 
;
COMMENT ON COLUMN parser.blob IS
  'Blob of single email mime message parsed by perl Mime::Parser->parser()'
;


DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
  	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'::udig
    WHERE
    	false
;
COMMENT ON VIEW rummy IS
  'Known unknown blobs in schema mimetool'
;

END TRANSACTION;
