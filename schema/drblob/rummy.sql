/*
 *  Synopsis:
 *	Summarize tables partially flowed.
 *  Usage:
 *	psql -f rummy.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	What about the cube() operator summarize all combinations?
 *
 *	Should rummy query be view?
 */

\set ON_ERROR_STOP on
\timing on
set search_path to drblob,public;

\echo

\echo Counting all Blobs in drbill (need service table?)
select
	count(blob) as "drbill Blob count"
  from (
    select
    	blob
      from
      	is_brr_log
    union
    select
     	blob
      from
      	is_fdr_log
    union
    select
     	blob
      from
      	is_qdr_log
  ) as all_blobs
;

\echo Selecting Rummy Blobs Set (ought to be empty)
select
	blob as "Rummy"
  from
  	is_brr_log bl
	  natural left outer join brr_log_total tot
	  natural left outer join brr_log_time tim
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
	blob as "Rummy"
  from
  	is_fdr_log fl
	  natural left outer join fdr_log_total tot
	  natural left outer join fdr_log_time tim
	  natural left outer join fdr_log_sequence seq
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
	blob
  from
  	is_qdr_log ql
	  natural left outer join qdr_log_total tot
	  natural left outer join qdr_log_time tim
	  natural left outer join qdr_log_flow_sequence seq
	  natural left outer join qdr_log_query q
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
	blob
  from
  	is_xdr_log ql
	  natural left outer join xdr_log_total tot
	  natural left outer join xdr_log_time tim
	  natural left outer join xdr_log_flow_sequence seq
	  natural left outer join xdr_log_query q
  where
  	ql.is_xdr is true
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
