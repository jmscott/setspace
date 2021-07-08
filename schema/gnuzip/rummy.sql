/*
 *  Synopsis:
 *	Find recent blobs in service but not in a table in gnufile.*
 */
SELECT
	t.blob
  FROM
  	gnuzip.gunzip_test_quiet t
	  LEFT OUTER JOIN gnuzip.gunzip_uncompressed_name n
	    ON
	    	(n.blob = t.blob)
	  LEFT OUTER JOIN gnuzip.gunzip_uncompressed_byte_count bc
	    ON
	  	(bc.blob = t.blob)
  WHERE
  	t.exit_status = 0
	AND
	(
		n.blob IS NULL
		OR
		bc.blob IS NULL
	)
;
