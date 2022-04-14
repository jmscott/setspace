/*
 *  Synopsis:
 *	Schema for famous perl5	Mail::Box packages.
 */
\set ON_ERROR_STOP true
\timing on

BEGIN TRANSACTION;

DROP SCHEMA IF EXISTS p5mail CASCADE;
CREATE SCHEMA p5mail;
COMMENT ON SCHEMA p5mail IS
  'Schema for famous perl5 Mail::Box packages'
;
SET search_path TO p5mail,public;

DROP TABLE IF EXISTS eml_header2json CASCADE;
CREATE TABLE eml_header2json (
	eml_blob	udig
				PRIMARY KEY
				REFERENCES setcore.service(blob),
	json_blob	udig	REFERENCES jsonorg.jsonb_255(blob)
				ON DELETE CASCADE,

	UNIQUE (json_blob)
);
CREATE INDEX eml_header2json_hash ON eml_header2json USING hash(eml_blob);
COMMENT ON TABLE eml_header2json IS
  'JSON Output of schema sbin/eml_header2json.pl'
;

DROP TABLE IF EXISTS box_parser CASCADE;
CREATE TABLE box_parser (
	blob		udig
				PRIMARY KEY
				REFERENCES setcore.service(blob),
	default_parser_type
			text CHECK (
				default_parser_type ~ '^[[:graph:]]{1,64}$'
			) NOT NULL,

	header_count	bigint CHECK (
				header_count >= 0
			) NOT NULL
);
CREATE INDEX box_parser_hash ON box_parser USING hash(blob);

DROP TABLE IF EXISTS box_parser_readHeader CASCADE;
CREATE TABLE box_parser_readHeader
(
	blob		udig
				REFERENCES box_parser(blob),
	eml_order	bigint CHECK (
				eml_order >= 0	
			),
	field		text CHECK (
				length(field) < 256

				/*  Note: readHeader() returns empty field!
				  AND
				field ~ '[[:graph:]]'
				*/
			) NOT NULL,
	value		text CHECK (
				length(value) < 4096
			) NOT NULL,

	PRIMARY KEY	(blob, eml_order)
);
CREATE INDEX box_parser_readHeader_fld_idx ON
  box_parser_readHeader(blob, field)
; 

DROP VIEW IF EXISTS rummy CASCADE;
CREATE VIEW rummy AS
  SELECT
  	'btc20:fd7b15dc5dc2039556693555c2b81b36c8deec15'::udig
    WHERE
    	false
;
COMMENT ON VIEW rummy IS
  'Known unknown blobs in schema p5mail'
;

END TRANSACTION;
