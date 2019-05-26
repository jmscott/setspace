/*
 *  Synopsis:
 *	Merge a fdr_log_total tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-fdr_log_total.sql <bio4d.fdr
 *	bio-cat sha:abc ... | psql -f merge-fdr_log_total.sql
 *  Blame:
 *  	jmscott@setspace.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_fdr_log.sql

INSERT into drblob.fdr_log_total (
	blob,
	record_count,
	blob_count,
	ok_sum,
	fault_sum
) SELECT
	:blob,
	(select
		count(*)
	  from
	  	merge_fdr_log
	) record_count,

	(select
		count(distinct blob)
	  from
	  	merge_fdr_log
	) as blob_count,

	(select
		sum(ok_count)
	  from
	  	merge_fdr_log
	) ok_sum,

	(select
		sum(fault_count)
	  from
	  	merge_fdr_log
	) fault_sum
  ON CONFLICT
  	do nothing
;
