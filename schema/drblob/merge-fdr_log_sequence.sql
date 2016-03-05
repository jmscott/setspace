/*
 *  Synopsis:
 *	Merge a fdr_log_sequence tuple built from log blob read from stdin
 *  Usage:
 *	psql -f merge-fdr_log_sequence.sql <flowd.fdr
 *	bio-cat sha:abc ... | psql -f merge-fdr_log_sequence.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_fdr_log.sql

INSERT into drblob.fdr_log_sequence (
	blob,
	min_sequence,
	max_sequence
) SELECT
	:blob,
	(SELECT
		min(sequence)
	  FROM
	  	merge_fdr_log
	) min_sequence,

	(SELECT
		max(sequence)
	  FROM
	  	merge_fdr_log
	) max_sequence
  ON CONFLICT
  	do nothing
;
