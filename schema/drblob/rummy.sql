/*
 *  Synopsis:
 *	Summarize tables partially flowed.
 *  Usage:
 *	psql -f rummy.sql
 *  See:
 *	sbin/rummy
 */
select
	bl.blob
  from
  	drblob.is_brr_log bl
	  inner join setspace.service s on (s.blob = bl.blob)
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
	s.discover_time >= now() + :since
UNION
select
	fl.blob
  from
  	drblob.is_fdr_log fl
	  inner join setspace.service s on (s.blob = fl.blob)
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
	s.discover_time >= now() + :since
UNION
select
	ql.blob
  from
  	drblob.is_qdr_log ql
	  inner join setspace.service s on (s.blob = ql.blob)
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
	s.discover_time >= now() + :since
UNION
select
	xl.blob
  from
  	drblob.is_xdr_log xl
	  inner join setspace.service s on (s.blob = xl.blob)
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
	s.discover_time >= now() + :since
;
