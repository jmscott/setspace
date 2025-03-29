/*
 *  Synopsis:
 *	List details of blobs in table fffile5.blob, ordered by discover time
 *  Usage:
 *	psql --file ssq-fffile5-ls.sql
 *  Note:
 */
SET search_path TO fffile5,setspace,public;

SELECT
	b.blob AS "Blob",
	f.file_type AS "File Type",
	ft.mime_type AS "Mime Type",
	fe.mime_encoding AS "Mime Encoding",
	CASE
	  WHEN flt.blob IS NULL THEN 'No'
	  ELSE 'Yes'
	END AS "Is Faulted",
	CASE
	  WHEN rum.blob IS NULL THEN 'No'
	  ELSE 'Yes'
	END AS "Is Rummy",
	interval_terse_english(now() - b.discover_time) || ' ago @ ' ||
		b.discover_time AS "Discovered"
  FROM
  	blob b
  	  NATURAL LEFT OUTER JOIN file f
  	  NATURAL LEFT OUTER JOIN file_mime_type ft
  	  NATURAL LEFT OUTER JOIN file_mime_encoding fe
	  NATURAL LEFT OUTER JOIN fault flt
	  NATURAL LEFT OUTER JOIN rummy rum
  WHERE
  	b.blob = :'blob'
  ORDER BY
  	b.discover_time DESC,
	b.blob ASC
;
