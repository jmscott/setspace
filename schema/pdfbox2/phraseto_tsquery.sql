/*
 *  Synopsis:
 *	Convert phrase words to parasble tsquery via function phrase_tsquery()
 *
 *  Command Line Variables:
 *	phrase		text
 *	ts_conf		text
 *
 *  Usage:
 *	psql 								\
 *	  --var phrase="'Compact Proofs of Retrievability'"		\
 *	  --var ts_conf="'english'"					\
 *	  --file phraseto_tsquery.sql
 *  Note:
 *	Should this query be in schema pgtexts (or pgfts)?
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Phrase are :phrase, Text Search Configuration is :ts_conf
\echo

select
	phraseto_tsquery(:ts_conf, :phrase)
;
