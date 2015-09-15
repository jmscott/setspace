/*
 *  Synopsis:
 *	Merge a xdr_log_time tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-xdr_log_time.sql <biod.xdr
 *	bio-cat sha:abc ... | psql -f merge-xdr_log_time.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
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
	(select
		min(start_time)
	  from
	  	merge_xdr_log
	) min_start_time,

	(select
		max(start_time)
	  from
	  	merge_xdr_log
	) max_start_time,

	(select
		min(wall_duration)
	  from
	  	merge_xdr_log
	) min_wall_duration,

	(select
		max(wall_duration)
	  from
	  	merge_xdr_log
	) max_wall_duration,

	(select
		min(system_duration)
	  from
	  	merge_xdr_log
	) min_system_duration,

	(select
		max(system_duration)
	  from
	  	merge_xdr_log
	) max_system_duration,

	(select
		min(user_duration)
	  from
	  	merge_xdr_log
	) min_user_duration,

	(select
		max(user_duration)
	  from
	  	merge_xdr_log
	) max_user_duration
  ON CONFLICT
  	do nothing
;
