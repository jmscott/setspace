/*
 *  Synopsis:
 *	List all known attributes of a blob in schema fffile5
 *  Usage:
 *	BLOB=btc20:2f022f92c43c519131f3906590d1953a80fea63a
 *	psql --set blob=$BLOB -f ssq-fffile5-ls.sql;
 */
SELECT
	f.blob AS "Blob",
	f.file_type AS "File Type",
	fmt.mime_type AS "Mime Type",
	fme.mime_encoding AS "Mime Encoding",
	CASE
	  WHEN flt.blob IS NULL THEN 'No'
	  ELSE 'Yes'
	END AS "Faulted?",
	CASE
	  WHEN rum.blob IS NULL THEN 'No'
	  ELSE 'Yes'
	END AS "Rummy?"
  FROM
  	fffile5.file f
  	  LEFT OUTER JOIN fffile5.file_mime_type fmt ON (
	  	fmt.blob = f.blob
	  )
  	  LEFT OUTER JOIN fffile5.file_mime_encoding fme ON (
	  	fme.blob = f.blob
	  )
	  LEFT OUTER JOIN fffile5.fault flt ON (flt.blob = f.blob)
	  LEFT OUTER JOIN fffile5.rummy rum ON (rum.blob = f.blob)
  WHERE
  	f.blob = :'blob'
;
