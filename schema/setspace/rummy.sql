/*
 *  Synopsis:
 *	Summarize tables partially flowed.
 *  Usage:
 *	psql -f rummy.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

\set ON_ERROR_STOP on
\timing on
set search_path to setspace,public;
\x on

\echo summarizing rummy state of all tables over all time
select
	(select
		count(*)
	  from
	  	service
	) as "service Total",

	(select
		count(*)
	  from
	  	service
		  natural left outer join byte_count bc
	  where
	  	bc.blob is null
	) as "No byte_count Total",

	(select
		count(*)
	  from
	  	service
		  natural left outer join byte_bitmap bm
	  where
	  	bm.blob is null
	) as "No byte_bitmap Total",

	(select
		count(*)
	  from
	  	service
		  natural left outer join is_utf8wf u8
	  where
	  	u8.blob is null
	) as "No is_utf8wf Total",

	(select
		count(*)
	  from
	  	service
		  natural left outer join byte_prefix_32 bp32
	  where
	  	bp32.blob is null
	) as "No byte_prefix_32 Total",

	(select
		count(*)
	    from
	    	is_utf8wf u8
		  natural left outer join is_udigish ud
	    where
	    	u8.is_utf8
		and
		ud.blob is null
	) as "No is_udigish for is_utf8wf Total"
;
\x off

select now() as "Current Time";

\echo selecting udigs with unknown rummy states
(select
	s.blob as "Known Unknowns"
  from
  	service s
	  natural left outer join byte_count bc
	  natural left outer join byte_bitmap bm
	  natural left outer join byte_prefix_32 bp32
	  natural left outer join is_utf8wf u8
  where
  	bc.blob is null
	or
	bm.blob is null
	or
	u8.blob is null
	or
	bp32.blob is null
) union (
  select
	u8.blob
    from
  	setspace.is_utf8wf u8
	  natural left outer join setspace.is_udigish ud
    where
  	u8.is_utf8 = true
	and
	ud.blob is null
)
;
