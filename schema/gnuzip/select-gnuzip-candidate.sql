/*
 *  Synopsis:
 *	Select possible gnuzip candidate blobs.
 *  Usage:
 *	psql --file select-gnuzip.sql
 */
\set QUIET on
\pset tuples_only
\timing
\pset null Unknown

\x on

SELECT
	p32.blob AS "Blob",
	pg_size_pretty(bc.byte_count) AS "Byte Count",
	s.discover_time AS "Discovered"
  FROM
  	setcore.byte_prefix_32 p32
	  JOIN setcore.service s ON (s.blob = p32.blob)
	  LEFT OUTER JOIN setcore.byte_count bc ON (bc.blob = p32.blob)
  WHERE
  	p32.prefix::text ~ '^\\x1f8b'
  ORDER BY
  	s.discover_time DESC
;
