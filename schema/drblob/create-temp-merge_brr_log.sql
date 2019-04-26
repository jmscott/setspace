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
 *  Note:
 *	Use the blobio domains for timestamp, name, etc.
 */
CREATE TEMPORARY TABLE merge_brr_log
(
	start_time	timestamptz
				NOT NULL,
	netflow		text
				CHECK (
					-- see blobio/README
					netflow ~
				       '^[a-z][a-z0-9]{0,7}~[[:graph:]]{1,128}$'
				)
				NOT NULL,
	verb		text
				CHECK (
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
				NOT NULL,
	blob		udig
				NOT NULL,
	chat_history	text
				CHECK (
					chat_history in (
						'ok',
						'ok,ok',
						'ok,ok,ok',

						'no',
						'ok,no',
						'ok,ok,no'
					)
				)
				NOT NULL,
	blob_size	bigint
				CHECK (
					blob_size >= 0
				)
				NOT NULL,
	wall_duration	interval
				CHECK (
					wall_duration >= '0'::interval
				)
				NOT NULL
);
\copy merge_brr_log from pstdin
ANALYZE merge_brr_log;
