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
CREATE TEMPORARY TABLE merge_xdr_log
(
	start_time		timestamptz
					NOT NULL,

	flow_sequence		bigint CHECK (
					flow_sequence > 0
				)
				NOT NULL,

	command_name		text CHECK (
					command_name ~
					      '^[[:alpha:]][[:alnum:]_]{0,64}$'
				)
				NOT NULL,

	termination_class	text CHECK (
					termination_class in (
						'OK',
						'ERR'
					)
				) NOT NULL,

	blob			udig
					NOT NULL,

	termination_code	bigint CHECK (
					termination_code >= 0
				)
				NOT NULL,

	wall_duration		interval CHECK (
					wall_duration >= '0'::interval
				)
				NOT NULL,

	system_duration		interval CHECK (
					system_duration >= '0'::interval
				)
				NOT NULL,

	user_duration		interval CHECK (
					user_duration >= '0'::interval
				)
				NOT NULL
);
\copy merge_xdr_log from pstdin
ANALYZE merge_xdr_log;
