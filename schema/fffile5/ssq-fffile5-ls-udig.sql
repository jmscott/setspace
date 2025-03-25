/*
 *  Synopsis:
 *	List details of a particular blob in schema fffile5.
 *  Usage:
 *	BLOB=btc20:2f022f92c43c519131f3906590d1953a80fea63a
 *	psql --set blob=$BLOB -f ssq-fffile5-ls.sql;
 *  Note:
 *	- Convert discover duration to more readable english like
 *
 *		00:50:29.673986 -> 40m 30s
 */
SELECT
	b.blob AS "Blob",
	f.file_type AS "File Type",
	ft.mime_type AS "Mime Type",
	fe.mime_encoding AS "Mime Encoding",
	CASE
	  WHEN flt.blob IS NULL THEN 'No'
	  ELSE 'Yes'
	END AS "In Fault",
	CASE
	  WHEN rum.blob IS NULL THEN 'No'
	  ELSE 'Yes'
	END AS "Is Rummy",
	discover_time AS "Discovered"
  FROM
  	fffile5.blob b
  	  LEFT OUTER JOIN fffile5.file f ON (
	  	f.blob = b.blob
	  )
  	  LEFT OUTER JOIN fffile5.file_mime_type ft ON (
	  	ft.blob = b.blob
	  )
  	  LEFT OUTER JOIN fffile5.file_mime_encoding fe ON (
	  	fe.blob = b.blob
	  )
	  LEFT OUTER JOIN fffile5.fault flt ON (flt.blob = b.blob)
	  LEFT OUTER JOIN fffile5.rummy rum ON (rum.blob = b.blob)
  WHERE
  	b.blob = :'blob'
;
