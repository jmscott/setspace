/*
 *  Synopsis:
 *	Merge a xdr_log_total tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-xdr_log_total.sql <biod.xdr
 *	bio-cat sha:abc ... | psql -f merge-xdr_log_total.sql
 *  Blame:
 *  	jmscott@setspace.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_xdr_log.sql

INSERT INTO drblob.xdr_log_total (
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
	(SELECT
		count(*)
	  FROM
	  	merge_xdr_log
	) record_count,

	(SELECT
		count(distinct flow_sequence)
	  FROM
	  	merge_xdr_log
	) as flow_seq_count,

	(SELECT
		count(distinct command_name)
	  FROM
	  	merge_xdr_log
	) command_name_count,

	(SELECT
		count(termination_class)
	  FROM
	  	merge_xdr_log
	  WHERE
	  	termination_class = 'OK'
	) OK_count,

	(SELECT
		count(termination_class)
	  FROM
	  	merge_xdr_log
	  WHERE
	  	termination_class = 'ERR'
	) ERR_count,

	(SELECT
		count(distinct blob)
	  FROM
	  	merge_xdr_log
	) blob_count,

	(SELECT
		count(distinct termination_code)
	  FROM
	  	merge_xdr_log
	) termination_code_count
  ON CONFLICT
  	DO NOTHING
;
