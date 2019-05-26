/*
 *  Synopsis:
 *	Merge a xdr_log_query tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-xdr_log_query.sql <bio4d.xdr
 *	bio-cat sha:abc ... | psql -f merge-xdr_log_query.sql
 *  Blame:
 *  	jmscott@setspace.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_xdr_log.sql

CREATE INDEX command_name_idx ON merge_xdr_log(command_name);

INSERT INTO drblob.xdr_log_query (
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
) SELECT
	:blob,
	x1.command_name,
	count(x1.blob) AS record_count,
	count(distinct x1.blob) AS blob_count,
	(SELECT
		count(x2.blob)
	  FROM
	  	merge_xdr_log x2
	  WHERE
		x2.command_name = x1.command_name
		AND
		x2.termination_class = 'OK'
	) AS OK_count,
	(SELECT
		count(x2.blob)
	  FROM
	  	merge_xdr_log x2
	  WHERE
		x2.command_name = x1.command_name
		AND
		x2.termination_class = 'ERR'
	) AS ERR_count,

	min(x1.start_time) AS min_start_time,
	max(x1.start_time) AS max_start_time,
	min(x1.wall_duration) AS min_wall_duration,
	max(x1.wall_duration) AS max_wall_duration,
	min(x1.user_duration) AS min_user_duration,
	max(x1.user_duration) AS max_user_duration,
	min(x1.system_duration) AS min_system_duration,
	max(x1.system_duration) AS max_system_duration,

	min(x1.flow_sequence) AS min_flow_sequence,
	max(x1.flow_sequence) AS max_flow_sequence,

	count(distinct x1.termination_code) AS termination_code_count
  FROM
  	merge_xdr_log x1
  GROUP BY
  	x1.command_name
  ON CONFLICT
  	do nothing
;
