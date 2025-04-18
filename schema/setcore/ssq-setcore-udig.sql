/*
 *  Synopsis:
 *	Detail listing of a blob in setcore service
 *  Usage:
 *	#  see script ssq-setcore-ls
 */
SET search_path TO setcore,setspace;

SELECT
	b.blob AS "Blob",
	interval_terse_english(age(now(), b.discover_time)) || ' ago @ ' ||
		b.discover_time AS "Discovered",
	pg_size_pretty(bc.byte_count) AS "Byte Count",
	CASE
	  WHEN u8.is_utf8 THEN 'Yes'
	  WHEN NOT u8.is_utf8 THEN 'No'
	  ELSE u8.is_utf8::text
	END AS "UTF-8",

	encode(p32.prefix, 'escape') AS "32 Byte Prefix",
	encode(s32.suffix, 'escape') AS "32 Byte Suffix",
	bb.bitmap::text AS "Byte Bitmap"
  FROM
  	blob b
	  LEFT OUTER JOIN byte_count bc ON (bc.blob = b.blob)
	  LEFT OUTER JOIN is_utf8wf u8 ON (u8.blob = b.blob)
	  LEFT OUTER JOIN byte_prefix_32 p32 ON (p32.blob = b.blob)
	  LEFT OUTER JOIN byte_suffix_32 s32 ON (s32.blob = b.blob)
	  LEFT OUTER JOIN byte_bitmap bb ON (bb.blob = b.blob)
  WHERE
  	b.blob = :'blob'
;
