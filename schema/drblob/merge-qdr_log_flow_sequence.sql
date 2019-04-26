/*
 *  Synopsis:
 *	Merge a qdr_log_flow_sequence tuple built from log blob read from stdin
 *  Usage:
 *	psql -f merge-qdr_log_flow_sequence.sql <flowd.qdr
 *	bio-cat sha:abc ... | psql -f merge-qdr_log_flow_sequence.sql
 *  Blame:
 *  	jmscott@setspace.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_qdr_log.sql

INSERT into drblob.qdr_log_flow_sequence (
	blob,
	min_sequence,
	max_sequence
) SELECT
	:blob,
	(select
		min(flow_sequence)
	  from
	  	merge_qdr_log
	) min_sequence,

	(select
		max(flow_sequence)
	  from
	  	merge_qdr_log
	) max_sequence
  ON CONFLICT
  	do nothing
;
