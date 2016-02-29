/*
 *  Synopsis:
 *	Create a temporary table suitable for query detail records
 *  Usage:
 *	#  in psql
 *	\i lib/create-temp-merge_qdr_log.sql
 *  See:
 *	schema/drblob/lib/merge-qdr_log_total.sql
 *	schema/drblob/lib/merge-qdr_log_time.sql
 *	schema/drblob/lib/merge-qdr_log_flow_sequence.sql
 *	schema/drblob/lib/merge-qdr_log_query.sql
 *  Note:
 *	Constraint for wall_duration >= query_duration?
 *
 *	Use the blobio domains for timestamp, name, etc?
 */
CREATE TEMPORARY TABLE merge_qdr_log
(
	start_time		timestamptz
					NOT NULL,

	flow_sequence		bigint CHECK (
					flow_sequence > 0
				) NOT NULL,

	query_name		text CHECK (
					query_name ~
					       '^[[:alpha:]][[:alnum:]_]{0,64}$'
				) NOT NULL,

	termination_class	text CHECK (
					termination_class in (
						'OK',
						'ERR'
					)
				) NOT NULL,

	blob			udig
					NOT NULL,

	--  sqlstate ought to be a domain

	sqlstate		text CHECK (
					sqlstate ~ '^[0-9A-Z]{5}$'
				) NOT NULL,

	rows_affected		bigint CHECK (
					rows_affected >= 0
				) NOT NULL,

	wall_duration		interval CHECK (
					wall_duration >= '0'::interval
				) NOT NULL,

	query_duration		interval CHECK (
					query_duration >= '0'::interval
				) NOT NULL
);
\copy merge_qdr_log from pstdin
ANALYZE merge_qdr_log;
