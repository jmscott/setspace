/*
 *  Synopsis:
 *	Detail listing of a blob in table mycore.blob
 *  Usage:
 *	#  see script ssq-mycore-ls
 */
SET search_path TO mycore,setspace;

SELECT
	b.blob AS "Blob",
	interval_terse_english(age(now(), b.discover_time)) || ' ago @ ' ||
		b.discover_time AS "Discovered",
	tit.title AS "Title"
  FROM
  	blob b
	  LEFT OUTER JOIN title tit ON (tit.blob = b.blob)
  WHERE
  	b.blob = :'blob'
;
