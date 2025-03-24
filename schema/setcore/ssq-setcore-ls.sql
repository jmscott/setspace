/*
 *  Synopsis:
 *	Detail listing of a blob in setcore service
 *  Usage:
 *	#  see script ssq-setcore-ls
 */
SET search_path TO setcore,setspace,public;

SELECT
	b.blob AS "Blob",
	regexp_replace(age(now(), b.discover_time)::text, '\..*', '') || ' ago'
                AS "Discovered",
	pg_size_pretty(byte_count) AS "Byte Count",
	CASE
	  WHEN is_utf8 THEN
	  	'Yes'
	  WHEN NOT is_utf8 THEN
	  	'No'
	  ELSE
	  	is_utf8
	END AS "UTF-8",

	encode(prefix, 'escape') AS "32 Byte Prefix",
	encode(suffix, 'escape') AS "32 Byte Suffix",
	bitmap::text AS "Byte Bitmap"
  FROM
  	setcore.blob b
	  NATURAL LEFT OUTER JOIN setcore.byte_count
	  NATURAL LEFT OUTER JOIN setcore.is_utf8wf
	  NATURAL LEFT OUTER JOIN setcore.byte_prefix_32
	  NATURAL LEFT OUTER JOIN setcore.byte_suffix_32
	  NATURAL LEFT OUTER JOIN setcore.byte_bitmap
  WHERE
  	b.blob = :'blob'
;
