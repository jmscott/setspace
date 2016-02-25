/*
 *  Synopsis:
 *	Find recent blobs in service but not in a table in fffile.*
 */
SELECT
	s.blob
  FROM
  	setspace.service s
	  LEFT OUTER JOIN fffile.file f ON (f.blob = s.blob)
	  LEFT OUTER JOIN fffile.file_mime_type ft ON (ft.blob = s.blob)
	  LEFT OUTER JOIN fffile.file_mime_encoding fe ON (fe.blob = s.blob)
  WHERE
  	(
		f.blob is null
		or
		ft.blob is null
		or
		fe.blob is null
	)
	AND
	s.discover_time BETWEEN (now() + :since) AND (now() + '-1 minute')
;
