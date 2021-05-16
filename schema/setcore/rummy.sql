/*
 *  Synopsis:
 *	Summarize tables with incomplete information since a point in time.
 *  Usage:
 *	psql -f rummy.sql --var since='-1 day'
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
  	s.discover_time >= now() + :'since'
	AND
	(
		bc.blob IS NULL
		OR
		bm.blob IS NULL
		OR
		u8.blob IS NULL
		OR
		bp32.blob IS NULL
		OR
		bs32.blob IS NULL
	)
;
