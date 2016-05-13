/*
 *  Synopsis:
 *	Merge a xdr_log_time tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-xdr_log_time.sql <biod.xdr
 *	bio-cat sha:abc ... | psql -f merge-xdr_log_time.sql
 *  Note:
 *	Investigate rewriting INSERTS using windowing functions.
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_xdr_log.sql

INSERT into drblob.xdr_log_time (
	blob,
	min_start_time,
	max_start_time,
	min_wall_duration,
	max_wall_duration,
	min_system_duration,
	max_system_duration,
	min_user_duration,
	max_user_duration
) SELECT
	:blob,
	(SELECT
		min(start_time)
	  FROM
	  	merge_xdr_log
	) min_start_time,

	(SELECT
		max(start_time)
	  FROM
	  	merge_xdr_log
	) max_start_time,

	(SELECT
		min(wall_duration)
	  FROM
	  	merge_xdr_log
	) min_wall_duration,

	(SELECT
		max(wall_duration)
	  FROM
	  	merge_xdr_log
	) max_wall_duration,

	(SELECT
		min(system_duration)
	  FROM
	  	merge_xdr_log
	) min_system_duration,

	(SELECT
		max(system_duration)
	  FROM
	  	merge_xdr_log
	) max_system_duration,

	(SELECT
		min(user_duration)
	  FROM
	  	merge_xdr_log
	) min_user_duration,

	(SELECT
		max(user_duration)
	  FROM
	  	merge_xdr_log
	) max_user_duration
  ON CONFLICT
  	DO NOTHING
;
