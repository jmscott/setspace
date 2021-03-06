/*
 *  Synopsis:
 *	Find recent blobs in service but not in a table in fffile.*
 */
SELECT
	DISTINCT s.blob
  FROM
  	setcore.service s
	  LEFT OUTER JOIN fffile.file f ON (f.blob = s.blob)
	  LEFT OUTER JOIN fffile.file_mime_type ft ON (ft.blob = s.blob)
	  LEFT OUTER JOIN fffile.file_mime_encoding fe ON (fe.blob = s.blob)
  WHERE
  	(
		f.blob IS NULL
		OR
		ft.blob IS NULL
		OR
		fe.blob IS NULL
	)
	AND
	s.discover_time between (now() + :since) AND (now() + '-1 minute')
	AND
	NOT EXISTS (
	  SELECT
	  	flt.blob
	    FROM
	    	fffile.fault flt
	    WHERE
	    	flt.blob = s.blob
	)
;
