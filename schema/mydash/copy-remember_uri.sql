/*
 *  Synopsis:
 *	Copy rows from version 1 table remember_uri to file remember_uri.row
 *  Usage:
 *	PGDATABASE=condor
 *	psql -f copy-remember_uri.sql
 */
\set ON_ERROR_STOP 1

\pset tuples_only
\pset format unaligned
\pset fieldsep '\t'

\o remember_uri.row

SELECT
	r.blob,
	r.uri as url,
	t.value as title,
	h.value as host,
	b.discover_time
  FROM
  	remember_uri r
	  JOIN blob b ON (b.id = r.blob)
	  LEFT JOIN remember_uri_host h ON (h.blob = r.blob)
	  LEFT JOIN remember_uri_title t ON (t.blob = r.blob)
  WHERE
  	substring(r.uri, E'\t') IS NULL
	AND
  	substring(t.value, E'\t') IS NULL
;
