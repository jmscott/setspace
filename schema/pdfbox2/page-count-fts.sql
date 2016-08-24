/*
 *  Synopsis:
 *	Count pdfs that match a full text search query.
 *
 *  Command Line Variables:
 *	ts_query		text
 *	ts_conf		text
 *
 *  Usage:
 *	psql 								\
 *	  --var ts_query="'suffix tree'"				\
 *	  --var ts_conf="'english'"					\
 *	  --file page-text-utf8-count-fts.sql
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Full text search :ts_query, Text Search Configuration is :ts_conf
\echo

select
	count(distinct pdf_blob) as matching_pdf_count
  from
	pdfbox2.page_tsv_utf8,
	to_tsquery(:ts_conf, :ts_query) q
  where
  	tsv @@ q
	and
	ts_conf = :ts_conf::text
;
