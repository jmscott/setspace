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
	tit.title AS "Title",
	tsv.tsv AS "Title Vector",
	CASE
	  WHEN req.blob IS NOT NULL THEN 'Yes'
	  ELSE 'No'
	END AS "Is Title Request"
  FROM
  	blob b
	  NATURAL LEFT OUTER JOIN title tit
	  NATURAL LEFT OUTER JOIN title_tsv tsv
	  NATURAL LEFT OUTER JOIN request_title req
  WHERE
  	b.blob = :'blob'
;
