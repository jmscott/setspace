/*
 *  Synopsis:
 *	Merge a fdr_log_time tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-fdr_log_time.sql <flowd.fdr
 *	bio-cat sha:abc ... | psql -f merge-fdr_log_time.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_fdr_log.sql

INSERT INTO drblob.fdr_log_time (
	blob,
	min_start_time,
	max_start_time,
	min_wall_duration,
	max_wall_duration
) SELECT
	:blob,
	(SELECT
		min(start_time)
	  FROM
	  	merge_fdr_log
	) min_start_time,

	(SELECT
		max(start_time)
	  FROM
	  	merge_fdr_log
	) max_start_time,

	(SELECT
		min(wall_duration)
	  FROM
	  	merge_fdr_log
	) min_wall_duration,

	(SELECT
		max(wall_duration)
	  FROM
	  	merge_fdr_log
	) max_wall_duration
  ON CONFLICT
  	DO NOTHING
;
