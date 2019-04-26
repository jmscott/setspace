/*
 *  Synopsis:
 *	Merge a qdr_log_query tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-qdr_log_query.sql <biod.qdr
 *	bio-cat sha:abc ... | psql -f merge-qdr_log_query.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  Note:
 *	Think about using a grouping set for OK/ERR_count attributes.
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_qdr_log.sql

create index query_name_idx on merge_qdr_log(query_name);

INSERT into drblob.qdr_log_query (
	blob,
	query_name,
	record_count,
	blob_count,
	OK_count,
	ERR_count,
	min_start_time,
	max_start_time,
	min_wall_duration,
	max_wall_duration,
	min_query_duration,
	max_query_duration,
	min_flow_sequence,
	max_flow_sequence,
	rows_affected,
	sqlstate_count
) select
	:blob,
	q1.query_name,
	count(q1.blob) as record_count,
	count(distinct q1.blob) as blob_count,
	(select
		count(q2.blob)
	  from
	  	merge_qdr_log q2
	  where
		q2.query_name = q1.query_name
		and
		q2.termination_class = 'OK'
	) as OK_count,
	(select
		count(q2.blob)
	  from
	  	merge_qdr_log q2
	  where
		q2.query_name = q1.query_name
		and
		q2.termination_class = 'ERR'
	) as ERR_count,
	min(q1.start_time) as min_start_time,
	max(q1.start_time) as max_start_time,
	min(q1.wall_duration) as min_wall_duration,
	max(q1.wall_duration) as max_wall_duration,
	min(q1.query_duration) as min_query_duration,
	max(q1.query_duration) as max_query_duration,
	min(q1.flow_sequence) as min_flow_sequence,
	max(q1.flow_sequence) as max_flow_sequence,
	sum(q1.rows_affected) as rows_affected,
	count(distinct q1.sqlstate) as sqlstate_count
  from
  	merge_qdr_log q1
  group by
  	q1.query_name
  ON CONFLICT
  	do nothing
;
