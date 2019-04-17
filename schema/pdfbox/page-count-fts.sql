/*
 *  Synopsis:
 *	Count pdfs that match a full text search query.
 *
 *  Command Line Variables:
 *	ts_query	text
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

SELECT
	count(DISTINCT pdf_blob) AS matching_pdf_count
  FROM
	pdfbox.page_tsv_utf8,
	to_tsquery(:ts_conf, :ts_query) q
  WHERE
  	tsv @@ q
	AND
	ts_conf = :ts_conf::regconfig
;
