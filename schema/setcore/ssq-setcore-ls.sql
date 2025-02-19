/*
 *  Synopsis:
 *	Detail listing of a blob in setcore service
 *  Usage:
 *	UDIG=sha:68446b07fe5b13906b3adbea298f9f2632eacecd
 *
 *	#  see script ssq-setcore-ls
 *	psql --set "blob=$UDIG"
 */
SELECT
	s.blob AS "Blob",
	regexp_replace(age(now(), s.discover_time)::text, '\..*', '') || ' ago'
                AS "Discovered",
	pg_size_pretty(bc.byte_count) AS "Byte Count",
	CASE
	  WHEN u8.is_utf8 IS NULL THEN
	  	'Unknown'
	  WHEN u8.is_utf8 THEN
	  	'Yes'
	  ELSE
	  	'No'
	END AS "UTF-8",
	CASE
	  WHEN p32.prefix IS NULL THEN
	  	'Unknown'
	  ELSE
	  	encode(p32.prefix, 'escape')
	END AS "32 Byte Prefix",
	CASE
	  WHEN s32.suffix IS NULL THEN
	  	'Unknown'
	  ELSE
	  	encode(s32.suffix, 'escape')
	END AS "32 Byte Suffix",
	bb.bitmap::text AS "Byte Bitmap"
  FROM
  	setcore.service s
	  LEFT OUTER JOIN setcore.byte_count bc ON (bc.blob = s.blob)
	  LEFT OUTER JOIN setcore.is_utf8wf u8 ON (u8.blob = s.blob)
	  LEFT OUTER JOIN setcore.byte_prefix_32 p32 ON (p32.blob = s.blob)
	  LEFT OUTER JOIN setcore.byte_suffix_32 s32 ON (s32.blob = s.blob)
	  LEFT OUTER JOIN setcore.byte_bitmap bb ON (bb.blob = s.blob)
  WHERE
  	s.blob = :'blob'
;
