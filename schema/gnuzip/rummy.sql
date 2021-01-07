/*
 *  Synopsis:
 *	Find recent blobs in service but not in a table in gnufile.*
 */
SELECT
	t.blob
  FROM
  	gnuzip.gunzip_test_quiet t
	  LEFT OUTER JOIN gnuzip.gunzip_list_verbose v ON (v.blob = t.blob)
  WHERE
  	t.exit_status = 0
	AND
	v.blob IS NULL
;
