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
SELECT
	count(DISTINCT pdf_blob) AS matching_pdf_count
  FROM
	pdfbox.page_tsv_utf8,
	plainto_tsquery(:ts_conf, :keyword) q
  WHERE
  	tsv @@ q
	AND
	ts_conf = :ts_conf::regconfig
;
