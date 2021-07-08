/*
 *  Synopsis:
 *	Summarize tables in setcore schema with incomplete information.
 *  Usage:
 *	psql -f rummy.sql | egrep '(sha|bc160):' | xargs bio-file
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
set search_path TO setcore,public;

SELECT
	DISTINCT s.blob
  FROM
  	setcore.service s
	  LEFT OUTER JOIN byte_count bc ON (bc.blob = s.blob)
	  LEFT OUTER JOIN byte_bitmap bm ON (bm.blob = s.blob)
	  LEFT OUTER JOIN byte_prefix_32 bp32 ON (bp32.blob = s.blob)
	  LEFT OUTER JOIN byte_suffix_32 bs32 ON (bs32.blob = s.blob)
	  LEFT OUTER JOIN is_utf8wf u8 ON (u8.blob = s.blob)
  where
	bc.blob IS NULL
	OR
	bm.blob IS NULL
	OR
	u8.blob IS NULL
	OR
	bp32.blob IS NULL
	OR
	bs32.blob IS NULL
;
