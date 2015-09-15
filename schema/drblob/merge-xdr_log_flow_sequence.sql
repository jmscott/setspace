/*
 *  Synopsis:
 *	Merge a xdr_log_flow_sequence tuple built from log blob read from stdin
 *  Usage:
 *	psql -f merge-xdr_log_flow_sequence.sql <flowd.xdr
 *	bio-cat sha:abc ... | psql -f merge-xdr_log_flow_sequence.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_xdr_log.sql

INSERT into drblob.xdr_log_flow_sequence (
	blob,
	min_sequence,
	max_sequence
) SELECT
	:blob,
	(select
		min(flow_sequence)
	  from
	  	merge_xdr_log
	) min_sequence,

	(select
		max(flow_sequence)
	  from
	  	merge_xdr_log
	) max_sequence
  ON CONFLICT
  	do nothing
;
