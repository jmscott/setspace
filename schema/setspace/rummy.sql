/*
 *  Synopsis:
 *	Summarize tables with incomplete information since a point in time.
 *  Usage:
 *	psql -f rummy.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
with recent_service as (
  select
  	s.blob
    from
    	setspace.service s
    where
	s.discover_time between (now() + :since) and (now() + '-1 minute')
)
 select
	rs.blob
  from
  	recent_service rs
	  left outer join setspace.byte_count bc on (bc.blob = rs.blob)
	  left outer join setspace.byte_bitmap bm on (bm.blob = rs.blob)
	  left outer join setspace.byte_prefix_32 bp32 on (bp32.blob = rs.blob)
	  left outer join setspace.byte_suffix_32 bs32 on (bs32.blob = rs.blob)
	  left outer join setspace.is_utf8wf u8 on (u8.blob = rs.blob)
  where
  	bc.blob is null
	or
	bm.blob is null
	or
	u8.blob is null
	or
	bp32.blob is null
	or
	bs32.blob is null
 union (
  select
	u8.blob
    from
  	setspace.is_utf8wf u8
	  inner join recent_service rs on (rs.blob = u8.blob)
	  left outer join setspace.is_udigish ud on (ud.blob = rs.blob)
	  left outer join setspace.new_line_count nc on (nc.blob = rs.blob)
    where
  	u8.is_utf8 = true
	and
	(
		ud.blob is null
		or
		nc.blob is null
	)
)
