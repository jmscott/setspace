/*
 *  Synopsis:
 *	Find known unknowns for all blobs discovered within a week
 *  Usage:
 *	psql --quiet --no-psqlrc -f rummy-week.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
\pset tuples_only on
\pset format unaligned

set search_path to setspace,public;

(select
	s.blob
  from
  	service s
	  natural left outer join byte_count bc
	  natural left outer join byte_bitmap bm
	  natural left outer join is_utf8wf u8
	  natural left outer join byte_prefix_32 bp32
  where
	s.discover_time >= now() + '-1 Week'
	and (
		bc.blob is null
		or
		bm.blob is null
		or
		u8.blob is null
		or
		bp32.blob is null
	)
) union (
  select
	u8.blob
  from
  	is_utf8wf u8
	  natural left outer join is_udigish ud
	  natural inner join service s
  where
  	ud.blob is null
	and
	s.discover_time >= now() + '-1 Week'
	and
	u8.is_utf8 is true
)
;
