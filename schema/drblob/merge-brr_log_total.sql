/*
 *  Synopsis:
 *	Merge a brr_log_total tuple built from log blob read from stdin of psql.
 *  Usage:
 *	psql -f merge-brr_log_total.sql <biod.brr
 *	bio-cat sha:abc ... | psql -f merge-brr_log_total.sql
 *  Blame:
 *  	jmscott@setspace.com
 */

\set ON_ERROR_STOP on

\include lib/create-temp-merge_brr_log.sql

INSERT into drblob.brr_log_total (
	blob,
	record_count,
	blob_count,
	ok_count,
	no_count,
	get_count,
	put_count,
	give_count,
	take_count,
	eat_count,
	wrap_count,
	roll_count
) SELECT
	:blob,
	(select
		count(*)
	  from
	  	merge_brr_log
	) record_count,

	(select
		count(distinct blob)
	  from
	  	merge_brr_log
	) as blob_count,

	(select
		count(chat_history)
	  from
	  	merge_brr_log
	  where
	  	chat_history ~ 'ok$'
	) ok_count,

	(select
		count(chat_history)
	  from
	  	merge_brr_log
	  where
	  	chat_history ~ 'no$'
	) no_count,

	(select
		count(verb)
	  from
	  	merge_brr_log
	  where
	  	verb = 'get'
	) as get_count,

	(select
		count(verb)
	  from
	  	merge_brr_log
	  where
	  	verb = 'put'
	) as put_count,

	(select
		count(verb)
	  from
	  	merge_brr_log
	  where
	  	verb = 'give'
	) as give_count,

	(select
		count(verb)
	  from
	  	merge_brr_log
	  where
	  	verb = 'take'
	) as take_count,

	(select
		count(verb)
	  from
	  	merge_brr_log
	  where
	  	verb = 'eat'
	) as eat_count,

	(select
		count(verb)
	  from
	  	merge_brr_log
	  where
	  	verb = 'wrap'
	) as wrap_count,

	(select
		count(verb)
	  from
	  	merge_brr_log
	  where
	  	verb = 'roll'
	) as roll_count
  ON CONFLICT
  	do nothing
;
