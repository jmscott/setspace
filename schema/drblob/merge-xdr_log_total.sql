/*
 *  Synopsis:
 *	Merge a xdr_log_total tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-xdr_log_total.sql <biod.xdr
 *	bio-cat sha:abc ... | psql -f merge-xdr_log_total.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_xdr_log.sql

INSERT into drblob.xdr_log_total (
	blob,
	record_count,
	flow_seq_count,
	command_name_count,
	OK_count,
	ERR_count,
	blob_count,
	termination_code_count
) SELECT
	:blob,
	(select
		count(*)
	  from
	  	merge_xdr_log
	) record_count,

	(select
		count(distinct flow_sequence)
	  from
	  	merge_xdr_log
	) as flow_seq_count,

	(select
		count(distinct command_name)
	  from
	  	merge_xdr_log
	) command_name_count,

	(select
		count(termination_class)
	  from
	  	merge_xdr_log
	  where
	  	termination_class = 'OK'
	) OK_count,

	(select
		count(termination_class)
	  from
	  	merge_xdr_log
	  where
	  	termination_class = 'ERR'
	) ERR_count,

	(select
		count(distinct blob)
	  from
	  	merge_xdr_log
	) blob_count,

	(select
		count(distinct termination_code)
	  from
	  	merge_xdr_log
	) termination_code_count
  ON CONFLICT
  	do nothing
;
