/*
 *  Synopsis:
 *	Merge a xdr_log_query tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-xdr_log_query.sql <biod.xdr
 *	bio-cat sha:abc ... | psql -f merge-xdr_log_query.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_xdr_log.sql

create index command_name_idx on merge_xdr_log(command_name);

INSERT into drblob.xdr_log_query (
	blob,
	command_name,
	record_count,
	blob_count,
	OK_count,
	ERR_count,
	min_start_time,
	max_start_time,
	min_wall_duration,
	max_wall_duration,
	min_user_duration,
	max_user_duration,
	min_system_duration,
	max_system_duration,
	min_flow_sequence,
	max_flow_sequence,
	termination_code_count
) select
	:blob,
	x1.command_name,
	count(x1.blob) as record_count,
	count(distinct x1.blob) as blob_count,
	(select
		count(x2.blob)
	  from
	  	merge_xdr_log x2
	  where
		x2.command_name = x1.command_name
		and
		x2.termination_class = 'OK'
	) as OK_count,
	(select
		count(x2.blob)
	  from
	  	merge_xdr_log x2
	  where
		x2.command_name = x1.command_name
		and
		x2.termination_class = 'ERR'
	) as ERR_count,

	min(x1.start_time) as min_start_time,
	max(x1.start_time) as max_start_time,
	min(x1.wall_duration) as min_wall_duration,
	max(x1.wall_duration) as max_wall_duration,
	min(x1.user_duration) as min_user_duration,
	max(x1.user_duration) as max_user_duration,
	min(x1.system_duration) as min_system_duration,
	max(x1.system_duration) as max_system_duration,

	min(x1.flow_sequence) as min_flow_sequence,
	max(x1.flow_sequence) as max_flow_sequence,

	count(distinct x1.termination_code) as termination_code_count
  from
  	merge_xdr_log x1
  group by
  	x1.command_name
  ON CONFLICT
  	do nothing
;
