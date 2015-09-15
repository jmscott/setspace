/*
 *  Synopsis:
 *	Create a temporary table suitable for blob request records
 *  Usage:
 *	\include lib/create-temp-merge_brr_log.sql
 *  See:
 *	lib/merge-brr_log_total.sql
 *	lib/merge-brr_log_time.sql
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Use the blobio domains for timestamp, name, etc.
 */
create temporary table merge_brr_log
(
	start_time	timestamptz
				not null,
	netflow		text
				check (
					-- see blobio/README
					netflow ~
				       '^[a-z][a-z0-9]{0,7}~[[:graph:]]{1,128}$'
				)
				not null,
	verb		text
				check (
					verb in (
						'get',
						'put',
						'give',
						'take',
						'eat',
						'wrap',
						'roll'
					)
				)
				not null,
	blob		udig
				not null,
	chat_history	text
				check (
					chat_history in (
						'ok',
						'ok,ok',
						'ok,ok,ok',

						'no',
						'ok,no',
						'ok,ok,no'
					)
				)
				not null,
	blob_size	bigint
				check (
					blob_size >= 0
				)
				not null,
	wall_duration	interval
				check (
					wall_duration >= '0'::interval
				)
				not null
);
\copy merge_brr_log from pstdin
analyze merge_brr_log;
