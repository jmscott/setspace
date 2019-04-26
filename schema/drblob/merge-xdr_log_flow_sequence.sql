/*
 *  Synopsis:
 *	Merge a xdr_log_flow_sequence tuple built FROM log blob read FROM stdin
 *  Usage:
 *	psql -f merge-xdr_log_flow_sequence.sql <flowd.xdr
 *	bio-cat sha:abc ... | psql -f merge-xdr_log_flow_sequence.sql
 *  Blame:
 *  	jmscott@setspace.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_xdr_log.sql

INSERT INTO drblob.xdr_log_flow_sequence (
	blob,
	min_sequence,
	max_sequence
) SELECT
	:blob,
	(SELECT
		min(flow_sequence)
	  FROM
	  	merge_xdr_log
	) min_sequence,

	(SELECT
		max(flow_sequence)
	  FROM
	  	merge_xdr_log
	) max_sequence
  ON CONFLICT
  	DO NOTHING
;
