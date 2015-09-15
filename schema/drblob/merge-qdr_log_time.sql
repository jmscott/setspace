/*
 *  Synopsis:
 *	Merge a qdr_log_time tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-qdr_log_time.sql <biod.qdr
 *	bio-cat sha:abc ... | psql -f merge-qdr_log_time.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_qdr_log.sql

INSERT into drblob.qdr_log_time (
	blob,
	min_start_time,
	max_start_time,
	min_wall_duration,
	max_wall_duration,
	min_query_duration,
	max_query_duration
) SELECT
	:blob,
	(select
		min(start_time)
	  from
	  	merge_qdr_log
	) min_start_time,

	(select
		max(start_time)
	  from
	  	merge_qdr_log
	) max_start_time,

	(select
		min(wall_duration)
	  from
	  	merge_qdr_log
	) min_wall_duration,

	(select
		max(wall_duration)
	  from
	  	merge_qdr_log
	) max_wall_duration,

	(select
		min(query_duration)
	  from
	  	merge_qdr_log
	) min_query_duration,

	(select
		max(query_duration)
	  from
	  	merge_qdr_log
	) max_query_duration
  ON CONFLICT
  	do nothing
;
