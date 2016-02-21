/*
 *  Synopsis:
 *	Summarize tables partially flowed.
 *  Usage:
 *	psql -f rummy.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
select
	s.blob
  from
  	setspace.service s
	  natural left outer join setspace.byte_count bc
	  natural left outer join setspace.byte_bitmap bm
	  natural left outer join setspace.byte_prefix_32 bp32
	  natural left outer join setspace.is_utf8wf u8
  where
  	bc.blob is null
	or
	bm.blob is null
	or
	u8.blob is null
	or
	bp32.blob is null
 union (
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
