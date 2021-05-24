/*
 *  Synopsis:
 *	Find recent blobs in service but not in a table in fffile5.*
 *  Usage:
 *	psql -f lib/rummy.sql --set since='1 year'
 */
SELECT
	DISTINCT s.blob
  FROM
  	setcore.service s
	  LEFT OUTER JOIN fffile5.file f ON (f.blob = s.blob)
	  LEFT OUTER JOIN fffile5.file_mime_type ft ON (ft.blob = s.blob)
	  LEFT OUTER JOIN fffile5.file_mime_encoding fe ON (fe.blob = s.blob)
  WHERE
  	(
		f.blob IS NULL
		OR
		ft.blob IS NULL
		OR
		fe.blob IS NULL
	)
	AND
	s.discover_time between (now() + :'since') AND (now() + '-1 minute')
	AND
	NOT EXISTS (
	  SELECT
	  	flt.blob
	    FROM
	    	fffile5.fault flt
	    WHERE
	    	flt.blob = s.blob
	)
;
