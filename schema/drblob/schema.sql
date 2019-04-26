/*
 *  Synopsis:
 *	Schema for flow, query, executable and blob.io detail records
 *  Usage:
 *	psql -f schema.sql
 *  Blame:
 *  	jmscott@setspace.com
 */
\set ON_ERROR_STOP on
\timing

begin;

drop schema if exists drblob cascade;
create schema drblob;

set search_path to drblob,pg_catalog,public;

drop domain if exists drblob.uint63 cascade;
create domain drblob.uint63 as bigint
  check (
  	value >= 0
 ) not null
;

drop domain if exists drblob.counter cascade;
create domain drblob.counter as drblob.uint63
  check (
  	value > 0
  )
;

drop domain if exists drblob.name cascade;
create domain drblob.name as text
  check (
  	value ~ '^[[:alpha:]][[:alnum:]_]{0,64}$'
  )
  not null
;

drop domain if exists drblob.duration cascade;
create domain drblob.duration as interval
  check (
  	value >= '0'::interval
  )
  not null
;

/*
 *  Is blob a log of blob request records.
 *  See the product blobio/biod for description of blob request records.
 */
drop table if exists drblob.is_brr_log;
create table drblob.is_brr_log
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,
	is_brr	bool
			not null
);
comment on table drblob.is_brr_log is
	'Is the Blob a Well Formed Blob Request Record (brr) Log'
;

/*
 *  Is blob a log of flow detail records.
 *  See the product blobio/flowd for description of flow detail records.
 */
drop table if exists drblob.is_fdr_log;
create table drblob.is_fdr_log
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,
	is_fdr	bool
			not null
);
comment on table drblob.is_fdr_log is
	'Is the Blob a Well Formed Flow Detail Record (fdr) Log'
;

/*
 *  Is blob a log of query detail records.
 *  See the product blobio/flowd for description of query detail records.
 */
drop table if exists drblob.is_qdr_log;
create table drblob.is_qdr_log
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,
	is_qdr	bool
			not null
);
comment on table drblob.is_qdr_log is
	'Is the Blob a Well Formed Query Detail Record (qdr) Log'
;

/*
 *  Is blob a log of process execution detail records.
 *  See the product blobio/flowd for description of process
 *  execution detail records.
 */
drop table if exists drblob.is_xdr_log;
create table drblob.is_xdr_log
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,
	is_xdr	bool
			not null
);
comment on table drblob.is_xdr_log is
	'Is the Blob a Well Formed Process Execution Detail Record (xdr) Log'
;

/*
 *  Various totals associated with a particular blob request record log blob.
 *
 *  Note:
 *	Notice summaries of blob sizes are ommited.
 */
drop table if exists drblob.brr_log_total;
create table drblob.brr_log_total
(
	blob		udig
				references setspace.service
				on delete cascade
				primary key,
	record_count	counter,

	--  distinct blob counts
	blob_count	counter,

	ok_count	uint63,
	no_count	uint63,

	--  request verb counts.

	get_count	uint63,
	put_count	uint63,
	give_count	uint63,
	take_count	uint63,
	eat_count	uint63,
	wrap_count	uint63,
	roll_count	uint63,

	constraint record_blob_compare check
	(
		record_count >= blob_count
	),

	--  at least one "ok" or {"no", "ok,no", "ok,ok,no"} request

	constraint ok_no_exist check
	(
		ok_count > 0
		or
		no_count > 0
	),

	--  at least one valid verb exists

	constraint verb_exists check
	(
		get_count > 0
		or
		put_count > 0
		or
		give_count > 0
		or
		take_count > 0
		or
		eat_count > 0
		or
		wrap_count > 0
		or
		roll_count > 0
	),

	--  sum of all verbs must equal record count
	constraint record_verb_total check
	(
		(
			get_count +
			put_count +
			give_count +
			take_count +
			eat_count +
			wrap_count +
			roll_count
		) = record_count
	)
);
comment on table drblob.brr_log_total is
	'Summary of Various Counts in a Blob Request Record Log'
;

drop table if exists drblob.brr_log_time;
create table drblob.brr_log_time
(
	blob			udig
					references setspace.service
					on delete cascade
					primary key,
	min_start_time		timestamptz
					not null,
	max_start_time		timestamptz
					not null,
	min_wall_duration	duration,
	max_wall_duration	duration,

	constraint min_max_start_time check (
		max_start_time >= min_start_time
	),

	constraint min_max_wall_duration check (
		max_wall_duration >= min_wall_duration
	)
);
comment on table drblob.brr_log_time is
	'Summary of Start Times and Wall Duration in Blob Request Record Log'
;

drop table if exists drblob.fdr_log_total;
create table drblob.fdr_log_total
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,

	record_count	counter,

	blob_count	counter,

	ok_sum		uint63,

	fault_sum	uint63,

	constraint record_blob_count check (
		record_count >= blob_count
	),

	--  Note: is this constraint always true?
	constraint ok_fault_non_zero check (
		
		ok_sum > 0
		or
		fault_sum > 0
	)
);
comment on table drblob.fdr_log_total is
	'Totals of blobs, oks and faults in Flow Detail Record Log'
;

drop table if exists drblob.fdr_log_time;
create table drblob.fdr_log_time
(
	blob			udig
					references setspace.service
					on delete cascade
					primary key,
	min_start_time		timestamptz
					not null,

	max_start_time		timestamptz
					not null,

	min_wall_duration	duration,

	max_wall_duration	duration,

	constraint min_max_start_time check (
		max_start_time >= min_start_time
	),

	constraint min_max_wall_duration check (
		max_wall_duration >= min_wall_duration
	)
);
comment on table drblob.fdr_log_time is
	'Summary of Start Times and Wall Duration in Flow Detail Record Log'
;

drop table if exists drblob.fdr_log_sequence;
create table drblob.fdr_log_sequence
(
	blob	udig
			references setspace.service
			on delete cascade
			primary key,

	min_sequence	counter,

	max_sequence	counter,

	constraint sequence_gt check (
		max_sequence >= min_sequence
	)
);

comment on table drblob.fdr_log_sequence is
	'Summary of Min/Max of Flow Detail Record Seuquence Ids'
;

drop table if exists drblob.qdr_log_total;
create table drblob.qdr_log_total
(
	blob			udig
					references setspace.service
					on delete cascade
					primary key,

	record_count		counter,

	flow_seq_count		counter,

	query_name_count	counter,

	OK_count		uint63,

	ERR_count		uint63,

	blob_count		counter,

	sqlstate_count		counter,

	constraint record_seq_gt check (
		record_count >= flow_seq_count
	),

	constraint record_OK_ERR_non_zero check (
		OK_count > 0
		or
		ERR_count > 0
	),

	constraint record_OK_ERR_count check (
		OK_count + ERR_count = record_count
	),

	constraint record_blob_gt check (
		record_count >= blob_count
	),

	constraint record_sqlstate_gt check (
		record_count >= sqlstate_count
	),

	constraint record_query_name check (
		record_count >= query_name_count
	)
);
comment on table drblob.qdr_log_total is
	'Totals of blobs, oks and faults in Query Detail Record Log'
;

drop table if exists drblob.qdr_log_time;
create table drblob.qdr_log_time
(
	blob			udig
					references setspace.service
					on delete cascade
					primary key,
	min_start_time		timestamptz
					not null,
	max_start_time		timestamptz
					not null,

	min_wall_duration	duration,
	max_wall_duration	duration,

	min_query_duration	duration,
	max_query_duration	duration,

	constraint min_max_start_time check (
		max_start_time >= min_start_time
	),

	constraint min_max_wall_duration check (
		max_wall_duration >= min_wall_duration
	),

	constraint min_max_query_duration check (
		max_query_duration >= min_query_duration
	)
);
comment on table drblob.qdr_log_time is
	'Summary of Start Times and Wall Duration in Query Detail Record Log'
;

drop table if exists drblob.qdr_log_flow_sequence;
create table drblob.qdr_log_flow_sequence
(
	blob			udig
					references setspace.service
					on delete cascade
					primary key,

	min_sequence		counter,
	max_sequence		counter,

	constraint min_max_flow_sequence check (
		max_sequence >= min_sequence
	)
);
comment on table drblob.qdr_log_flow_sequence is
	'Summary of Min/Max of Flow Sequence in Query Detail Record Log'
;

drop table if exists drblob.xdr_log_total;
create table drblob.xdr_log_total
(
	blob			udig
					references setspace.service
					on delete cascade
					primary key,

	record_count		counter,

	flow_seq_count		counter,

	command_name_count	counter,

	OK_count		uint63,
	ERR_count		uint63,

	blob_count		counter,

	termination_code_count	counter,

	constraint record_seq_gt check (
		record_count >= flow_seq_count
	),

	constraint record_OK_ERR_non_zero check (
		OK_count > 0
		or
		ERR_count > 0
	),

	constraint record_OK_ERR_count check (
		OK_count + ERR_count = record_count
	),

	constraint record_blob_gt check (
		record_count >= blob_count
	),

	constraint record_sqlstate_gt check (
		record_count >= termination_code_count
	),

	constraint record_command_name check (
		record_count >= command_name_count
	)
);
comment on table drblob.xdr_log_total is
	'Totals of blobs, in Process Execution Detail Record Log'
;

drop table if exists drblob.xdr_log_time;
create table drblob.xdr_log_time
(
	blob			udig
					references setspace.service
					on delete cascade
					primary key,
	min_start_time		timestamptz
					not null,
	max_start_time		timestamptz
					not null,

	min_wall_duration	duration,
	max_wall_duration	duration,

	min_system_duration	duration,
	max_system_duration	duration,

	min_user_duration	duration,
	max_user_duration	duration,

	constraint min_max_start_time check (
		max_start_time >= min_start_time
	),

	constraint min_max_wall_duration check (
		max_wall_duration >= min_wall_duration
	),

	constraint min_max_system_duration check (
		max_system_duration >= min_system_duration
	),

	constraint min_max_user_duration check (
		max_system_duration >= min_system_duration
	)
);
comment on table drblob.xdr_log_time is
	'Summary of Times and Durations in Process Executaion Detail Record Log'
;

drop table if exists drblob.xdr_log_flow_sequence;
create table drblob.xdr_log_flow_sequence
(
	blob			udig
					references setspace.service
					on delete cascade
					primary key,

	min_sequence		counter,
	max_sequence		counter,

	constraint min_max_flow_sequence check (
		max_sequence >= min_sequence
	)
);
comment on table drblob.xdr_log_flow_sequence is
    'Summary of Min/Max of Flow Sequence in Process Execution Detail Record Log'
;

drop table if exists drblob.qdr_log_query;
create table drblob.qdr_log_query
(
	blob			udig
					references setspace.service
					on delete cascade,

	query_name		name,

	record_count		counter,

	blob_count		counter,

	OK_count		uint63,

	ERR_count		uint63,

	min_start_time		timestamptz
					not null,

	max_start_time		timestamptz
					not null,

	min_wall_duration	duration,
	max_wall_duration	duration,

	min_query_duration	duration,
	max_query_duration	duration,

	min_flow_sequence	counter,
	max_flow_sequence	counter,

	rows_affected		uint63,
	sqlstate_count		counter,

	primary key		(blob, query_name),

	constraint record_blob_gt check (
		record_count >= blob_count
	),
	constraint OK_ERR_sum check (
		OK_count + ERR_count = record_count
	),
	constraint min_max_start_time_gt check (
		max_start_time >= min_start_time
	),
	constraint min_max_wall_duration_gt check (
		max_wall_duration >= min_wall_duration
	),
	constraint min_max_query_duration_gt check (
		max_query_duration >= min_query_duration
	),
	constraint record_sqlstate_gt check (
		record_count >= sqlstate_count
	),
	constraint flowsequence_ge check (
		max_flow_sequence >= min_flow_sequence
	)
);
comment on table drblob.qdr_log_query is
    'Summary of Particular Queries in a Query Detail Record Log'
;
drop table if exists xdr_log_query;
create table xdr_log_query
(
	blob			udig
					references setspace.service
					on delete cascade,
	command_name		name,

	record_count		counter,
	blob_count		counter,

	OK_count		uint63,
	ERR_count		uint63,
	termination_code_count	counter,

	min_flow_sequence	counter,
	max_flow_sequence	counter,

	min_start_time		timestamp,
	max_start_time		timestamp,

	min_wall_duration	duration,
	max_wall_duration	duration,

	min_user_duration	duration,
	max_user_duration	duration,

	min_system_duration	duration,
	max_system_duration	duration,

	constraint record_blob_ge check (
		record_count >= blob_count
	),

	constraint max_min_flowseq_ge check (
		max_flow_sequence >= min_flow_sequence
	),

	constraint max_min_start_time_ge check (
		max_start_time >= min_start_time
	),

	constraint OK_ERR_record_eq check (
		OK_count + ERR_count = record_count
	),

	constraint record_term_code_ge check (
		record_count >= termination_code_count
	),

	constraint max_min_wall_ge check (
		max_wall_duration >= min_wall_duration
	),

	constraint max_min_user_ge check (
		max_user_duration >= min_user_duration
	),

	constraint max_min_system_ge check (
		max_system_duration >= min_system_duration
	),

	primary key	(blob, command_name)
);

comment on table drblob.xdr_log_query is
    'Summary of Particular Process Commands in a Execution Detail Record Log'
;

drop view if exists drblob.service cascade;
create view drblob.service as
  select
  	blob
    from
    	drblob.is_brr_log
    where
    	is_brr
  union
  select
  	blob
    from
    	drblob.is_fdr_log
    where
    	is_fdr
  union
  select
  	blob
    from
    	drblob.is_qdr_log
    where
    	is_qdr
  union
  select
  	blob
    from
    	drblob.is_xdr_log
    where
    	is_xdr
;

commit;
