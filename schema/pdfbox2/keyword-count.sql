/*
 *  Synopsis:
 *	Count the PDF blobs on pages and titles
 *  Command Line Arguments: {
 *	"keywords": {
 *		"type":	"text"
 *	}
 *  }
 *
 *  Usage:
 *	psql -f keyword-count.sql --set keywords="'$KEYWORDS'"
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Keywords are :keywords
\echo

\x off
select
	count(distinct pdf.pdf_blob)
  from
  	pdfbox2.extract_page_utf8 pdf
	  join pgtexts.tsv_utf8 txt on (txt.blob = pdf.page_blob),
	plainto_tsquery('english', :keywords) as q
  where
	txt.doc @@ q
;
