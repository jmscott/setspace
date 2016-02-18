/*
 *  Synopsis:
 *	Create a temporary table suitable for flow detail records
 *  Usage:
 *	\include lib/create-temp-merge_fdr_log.sql
 *  See:
 *	lib/merge-fdr_log_total.sql
 *	lib/merge-fdr_log_time.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Use the blobio domains for timestamp, name, etc.
 */
CREATE TEMPORARY TABLE merge_fdr_log
(
	start_time	timestamptz
				NOT NULL,
	blob		udig
				NOT NULL,

	ok_count	bigint CHECK (
				ok_count >= 0
			)
			NOT NULL,

	fault_count	bigint check (
				fault_count >= 0
			)
			NOT NULL,

	wall_duration	interval CHECK (
				wall_duration >= '0'::interval
			)
			NOT NULL,

	sequence	bigint CHECK (
				sequence > 0
			)
);
\copy merge_fdr_log from pstdin
ANALYZE merge_fdr_log;
