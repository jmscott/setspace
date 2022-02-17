/*
 *  Synopsis:
 *	Merge a json blob into tables box_parser and box_parser_readHeader.
 *  Usage:
 *	JSON=
 *	psql -f merge-eml_header2json.sql blob=
 */
\set ON_ERROR_STOP 1
SET search_path TO p5mail,jsonorg,public;

BEGIN;

CREATE TEMP VIEW rummy AS
  SELECT
	j.blob AS json_blob,
	j.doc
  FROM
  	jsonb_255 j
	  LEFT OUTER JOIN eml_header2json e ON (
	  	e.json_blob = j.blob
	  )
  WHERE
  	e.json_blob IS NULL
	AND
  	j.doc->>'eml_blob' ~ '^[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}$'
	AND
	j.doc->>'now' ~ '^\d\d\d\d-\d\d-\d\dT'
	AND
	j.doc->>'default_parser_type' ~ '^Mail::Box::Parser::'
	AND
	(j.doc->>'header_count')::bigint > 0
	AND
	j.doc->'header' IS NOT NULL
	AND
	j.doc->'where' IS NOT NULL
;

\x

INSERT INTO eml_header2json(
	eml_blob,
	json_blob
 ) SELECT
 	(doc->>'eml_blob')::udig AS eml_blob,
	json_blob
    FROM
    	rummy
;
