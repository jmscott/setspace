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
create temporary table merge_fdr_log
(
	start_time	timestamptz
				not null,
	blob		udig
				not null,

	ok_count	bigint check (
				ok_count >= 0
			)
			not null,

	fault_count	bigint check (
				fault_count >= 0
			)
			not null,

	wall_duration	interval check (
				wall_duration >= '0'::interval
			)
			not null,

	sequence	bigint check (
				sequence > 0
			)
);
\copy merge_fdr_log from pstdin
analyze merge_fdr_log;
