/*
 *  Synopsis:
 *	Find recent blobs in service but not in a table in gnufile.*
 */
SELECT
	DISTINCT s.blob
  FROM
  	setcore.service s
  	  JOIN setcore.byte_prefix_32 p ON (p.blob = s.blob)
	  LEFT OUTER JOIN gnuzip.gunzip_test_quiet g ON (g.blob = p.blob)
  WHERE
	g.blob IS NULL
	AND
	s.discover_time between (now() + :since) AND (now() + '-1 minute')
	AND
	substr(p.prefix, 1, 2) = '\x1F8B'
;
