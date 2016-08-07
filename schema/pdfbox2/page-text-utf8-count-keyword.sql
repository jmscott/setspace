/*
 *  Synopsis:
 *	Count pdfs that match a keyword search.
 *
 *  Command Line Variables:
 *	keyword		text
 *	ts_conf		text
 *
 *  Usage:
 *	psql 								\
 *	  --var keyword="'$KEYWORDS'"					\
 *	  --var ts_conf="'english'"					\
 *	  --file keyword.sql
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Keywords are :keyword, Text Search Configuration is :ts_conf
\echo

\x on
select
	count(distinct pdf_blob) as matching_pdf_count
  from
	pdfbox2.page_tsv_utf8,
	plainto_tsquery(:ts_conf, :keyword) q
  where
  	tsv @@ q
	and
	ts_conf = :ts_conf::text
;
