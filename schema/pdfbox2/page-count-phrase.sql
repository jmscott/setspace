/*
 *  Synopsis:
 *	Count pdfs that match a phrase text search.
 *
 *  Command Line Variables:
 *	phrase		text
 *	ts_conf		text
 *
 *  Usage:
 *	psql 								\
 *	  --var phrase="'suffix tree'"					\
 *	  --var ts_conf="'english'"					\
 *	  --file page-text-utf8-count-phrase.sql
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Phrase are :phrase, Text Search Configuration is :ts_conf
\echo

\x on
select
	count(distinct pdf_blob) as matching_pdf_count
  from
	pdfbox2.page_tsv_utf8,
	phraseto_tsquery(:ts_conf, :phrase) q
  where
  	tsv @@ q
	and
	ts_conf = :ts_conf::text
;
