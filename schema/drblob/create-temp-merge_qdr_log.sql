/*
 *  Synopsis:
 *	Create a temporary table suitable for query detail records
 *  Usage:
 *	\i lib/create-temp-merge_qdr_log.sql
 *  See:
 *	lib/merge-qdr_log_total.sql
 *	lib/merge-qdr_log_time.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Constraint for wall_duration >= query_duration?
 *
 *	Use the blobio domains for timestamp, name, etc.
 */
create temporary table merge_qdr_log
(
	start_time		timestamptz
					not null,

	flow_sequence		bigint check (
					flow_sequence > 0
				)
				not null,

	query_name		text check (
					query_name ~
					       '^[[:alpha:]][[:alnum:]_]{0,64}$'
				)
				not null,

	termination_class	text check (
					termination_class in (
						'OK',
						'ERR'
					)
				) not null,

	blob			udig
					not null,

	sqlstate		text check (
					sqlstate ~ '^[0-9A-Z]{5}$'
				) not null,

	rows_affected		bigint check (
					rows_affected >= 0
				) not null,

	wall_duration		interval check (
					wall_duration >= '0'::interval
				)
				not null,

	query_duration		interval check (
					query_duration >= '0'::interval
				)
				not null
);
\copy merge_qdr_log from pstdin
analyze merge_qdr_log;
