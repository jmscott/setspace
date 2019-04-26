/*
 *  Synopsis:
 *	Summarize tables partially flowed.
 *  Usage:
 *	psql -f rummy.sql
 *  See:
 *	sbin/rummy
 *  Note:
 *	Rewrite query to use CTE for candidate blobs.
 */
select
	bl.blob
  from
  	drblob.is_brr_log bl
	  inner join setcore.service s on (s.blob = bl.blob)
	  left outer join drblob.brr_log_total tot on (tot.blob = bl.blob)
	  left outer join drblob.brr_log_time tim on (tim.blob = bl.blob)
  where
  	bl.is_brr is true
	and
	(
		tot.blob is null
		or
		tim.blob is null
	)
	and
	s.discover_time between (now() + :since) and (now() + '-1 minute')
UNION
select
	fl.blob
  from
  	drblob.is_fdr_log fl
	  inner join setcore.service s on (s.blob = fl.blob)
	  left outer join drblob.fdr_log_total tot on (tot.blob = fl.blob)
	  left outer join drblob.fdr_log_time tim on (tim.blob = fl.blob)
	  left outer join drblob.fdr_log_sequence seq on (seq.blob = fl.blob)
  where
  	fl.is_fdr is true
	and
	(
		tot.blob is null
		or
		tim.blob is null
		or
		seq.blob is null
	)
	and
	s.discover_time between (now() + :since) and (now() + '-1 minute')
UNION
select
	ql.blob
  from
  	drblob.is_qdr_log ql
	  inner join setcore.service s on (s.blob = ql.blob)
	  left outer join drblob.qdr_log_total tot on (tot.blob = ql.blob)
	  left outer join drblob.qdr_log_time tim on (tim.blob = ql.blob)
	  left outer join drblob.qdr_log_flow_sequence seq on (
	  	seq.blob = ql.blob
	  )
  where
  	ql.is_qdr is true
	and
	(
		tot.blob is null
		or
		tim.blob is null
		or
		seq.blob is null
		or

		--  at least one query detail record must exist

		not exists (
		  select
		  	q.blob
		    from
		    	drblob.qdr_log_query q
		    where
		    	q.blob = ql.blob
		)
	)
	and
	s.discover_time between (now() + :since) and (now() + '-1 minute')
UNION
select
	xl.blob
  from
  	drblob.is_xdr_log xl
	  inner join setcore.service s on (s.blob = xl.blob)
	  left outer join drblob.xdr_log_total tot on (tot.blob = xl.blob)
	  left outer join drblob.xdr_log_time tim on (tim.blob = xl.blob)
	  left outer join drblob.xdr_log_flow_sequence seq on (
		seq.blob = xl.blob
	  )
  where
  	xl.is_xdr is true
	and
	(
		tot.blob is null
		or
		tim.blob is null
		or
		seq.blob is null
		or

		--  at least one exec detail record must exist

		not exists (
		  select
		  	x.blob
		    from
		    	drblob.xdr_log_query x
		    where
		    	x.blob = xl.blob
		)
	)
	and
	s.discover_time between (now() + :since) and (now() + '-1 minute')
;
