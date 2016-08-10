/*
 *  Synopsis:
 *	Convert keywords to parsable tsquery via plainto_tsquery()
 *
 *  Command Line Variables:
 *	keyword		text
 *	ts_conf		text
 *
 *  Usage:
 *	psql 								\
 *	  --var keyword="'Compact Proofs of Retrievability'"		\
 *	  --var ts_conf="'english'"					\
 *	  --file plainto_tsquery.sql
 *  Note:
 *	Should this query be in schema pgtexts (or pgfts)?
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Keyword is :keyword, Text Search Configuration is :ts_conf
\echo

select
	plainto_tsquery(:ts_conf, :keyword)
;
