/*
 *  Synopsis:
 *	Copy rows from version 1 table my_title to file my_title.row
 *  Usage:
 *	PGDATABASE=condor
 *	psql -f select-my_title.sql | head -1 | my_title2title
 */
\set QUIET 1
\pset tuples_only
\pset format unaligned
\pset fieldsep '\t'

--  bash/zsh compress incorrectly contiguous empty fields into a single field,
--  render impossible proper parsing for tab separated chars.

\pset null NULL
SELECT
	t.blob,
	t.value,
	extract(epoch from b.discover_time)::bigint as discover_unix_epoch
  FROM
  	my_title t
	  JOIN blob b ON (b.id = t.blob)
  WHERE
  	t.value ~ '[[:graph:]]'
	AND
	substring(t.value, E'\t') IS NULL
;
