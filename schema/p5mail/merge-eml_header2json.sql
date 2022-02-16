/*
 *  Synopsis:
 *	Merge a json blob into tables box_parser and box_parser_readHeader.
 *  Usage:
 *	JSON=
 *	psql -f merge-eml_header2json.sql blob=
 */

SELECT
	count(*)
  FROM
  	jsonorg.jsonb_255
  WHERE
  	doc->>'eml_blob' ~ '^[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}$'
	AND
	doc->>'now' ~ '^\d\d\d\d-\d\d-\d\dT'
	AND
	doc->>'default_parser_type' ~ '^Mail::Box::Parser::'
	AND
	(doc->>'header_count')::bigint > 0
	AND
	doc->'header' IS NOT NULL
	AND
	doc->'where' IS NOT NULL
;
