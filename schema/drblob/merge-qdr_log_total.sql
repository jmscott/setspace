/*
 *  Synopsis:
 *	Merge a qdr_log_total tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-qdr_log_total.sql <biod.qdr
 *	bio-cat sha:abc ... | psql -f merge-qdr_log_total.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_qdr_log.sql

INSERT into drblob.qdr_log_total (
	blob,
	record_count,
	flow_seq_count,
	query_name_count,
	OK_count,
	ERR_count,
	blob_count,
	sqlstate_count
) SELECT
	:blob,
	(select
		count(*)
	  from
	  	merge_qdr_log
	) record_count,

	(select
		count(distinct flow_sequence)
	  from
	  	merge_qdr_log
	) as flow_seq_count,

	(select
		count(distinct query_name)
	  from
	  	merge_qdr_log
	) query_name_count,

	(select
		count(termination_class)
	  from
	  	merge_qdr_log
	  where
	  	termination_class = 'OK'
	) OK_count,

	(select
		count(termination_class)
	  from
	  	merge_qdr_log
	  where
	  	termination_class = 'ERR'
	) ERR_count,

	(select
		count(distinct blob)
	  from
	  	merge_qdr_log
	) blob_count,

	(select
		count(distinct sqlstate)
	  from
	  	merge_qdr_log
	) sqlstate_count
  ON CONFLICT
  	do nothing
;
