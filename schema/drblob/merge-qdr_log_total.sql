/*
 *  Synopsis:
 *	Merge a qdr_log_total tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-qdr_log_total.sql <bio4d.qdr
 *	bio-cat sha:abc ... | psql -f merge-qdr_log_total.sql
 *  Blame:
 *  	jmscott@setspace.com
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
	(SELECT
		count(*)
	  FROM
	  	merge_qdr_log
	) record_count,

	(SELECT
		count(distinct flow_sequence)
	  FROM
	  	merge_qdr_log
	) AS flow_seq_count,

	(SELECT
		count(distinct query_name)
	  FROM
	  	merge_qdr_log
	) query_name_count,

	(SELECT
		count(termination_class)
	  FROM
	  	merge_qdr_log
	  WHERE
	  	termination_class = 'OK'
	) OK_count,

	(SELECT
		count(termination_class)
	  FROM
	  	merge_qdr_log
	  WHERE
	  	termination_class = 'ERR'
	) ERR_count,

	(SELECT
		count(distinct blob)
	  FROM
	  	merge_qdr_log
	) blob_count,

	(SELECT
		count(distinct sqlstate)
	  FROM
	  	merge_qdr_log
	) sqlstate_count
  ON CONFLICT
  	DO NOTHING
;
