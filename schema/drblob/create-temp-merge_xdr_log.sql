/*
 *  Synopsis:
 *	Create a temporary table suitable for process execution detail records
 *  Usage:
 *	\i lib/create-temp-merge_xdr_log.sql
 *  See:
 *	lib/merge-xdr_log_total.sql
 *	lib/merge-xdr_log_time.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Constraint for wall_duration >= query_duration?
 *
 *	Use the blobio domains for timestamp, name, etc.
 */
create temporary table merge_xdr_log
(
	start_time		timestamptz
					not null,

	flow_sequence		bigint check (
					flow_sequence > 0
				)
				not null,

	command_name		text check (
					command_name ~
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

	termination_code	bigint check (
					termination_code >= 0
				)
				not null,

	wall_duration		interval check (
					wall_duration >= '0'::interval
				)
				not null,

	system_duration		interval check (
					system_duration >= '0'::interval
				)
				not null,

	user_duration		interval check (
					user_duration >= '0'::interval
				)
				not null
);
\copy merge_xdr_log from pstdin
analyze merge_xdr_log;
