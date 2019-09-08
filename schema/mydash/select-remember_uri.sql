/*
 *  Synopsis:
 *	Copy rows from version 1 table remember_uri to file remember_uri.row
 *  Usage:
 *	PGDATABASE=condor
 *	psql -f select-remember_uri.sql | head -1 | remember_uri2tag_http
 */
\set QUIET 1
\pset tuples_only
\pset format unaligned
\pset fieldsep '\t'

--  bash/zsh compress incorrectly contiguous empty fields into a single field,
--  render impossible proper parsing for tab separated chars.

\pset null NULL

SELECT
	r.blob,
	r.uri as url,
	CASE
	  WHEN
	  	t.value ~ '^[[:space:]]*$'
	  THEN
	  	NULL
	  ELSE
	  	t.value
	  END AS title,
	h.value as host,
	extract(epoch from b.discover_time)::bigint as discover_unix_epoch
  FROM
  	remember_uri r
	  JOIN blob b ON (b.id = r.blob)
	  LEFT JOIN remember_uri_host h ON (h.blob = r.blob)
	  LEFT JOIN remember_uri_title t ON (t.blob = r.blob)
  WHERE
  	substring(r.uri, E'\t') IS NULL
	AND
  	substring(t.value, E'\t') IS NULL
	AND
	r.uri ~ '^http(s)?:'
;
