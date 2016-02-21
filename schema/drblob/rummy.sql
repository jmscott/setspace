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
	  natural left outer join drblob.brr_log_total tot
	  natural left outer join drblob.brr_log_time tim
  where
  	bl.is_brr is true
	and
	(
		tot.blob is null
		or
		tim.blob is null
	)
UNION
select
	fl.blob as "Rummy"
  from
  	drblob.is_fdr_log fl
	  natural left outer join drblob.fdr_log_total tot
	  natural left outer join drblob.fdr_log_time tim
	  natural left outer join drblob.fdr_log_sequence seq
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
UNION
select
	ql.blob
  from
  	drblob.is_qdr_log ql
	  natural left outer join drblob.qdr_log_total tot
	  natural left outer join drblob.qdr_log_time tim
	  natural left outer join drblob.qdr_log_flow_sequence seq
	  natural left outer join drblob.qdr_log_query q
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
		q.blob is null
	)
UNION
select
	xl.blob
  from
  	drblob.is_xdr_log xl
	  natural left outer join drblob.xdr_log_total tot
	  natural left outer join drblob.xdr_log_time tim
	  natural left outer join drblob.xdr_log_flow_sequence seq
	  natural left outer join drblob.xdr_log_query q
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
		q.blob is null
	)
;
