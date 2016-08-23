/*
 *  Synopsis:
 *	Keyword search of pdfs by page, ranked by page "closest" to fts query.
 *
 *  Command Line Variables:
 *	keyword		text
 *	limit		uint16
 *	offset		ubigint
 *	ts_conf		text
 *
 *  Usage:
 *	psql								\
 *	  --var keywords="'$KEYWORDS'"					\
 *	  --var limit=10						\
 *	  --var offset=0						\
 *	  --file page-text-utf8-keyword.sql
 *  Note:
 *	Seems like the percent of matching pages in the pdf ought to be
 *	a weight, as well.  Also, the other pages "close" pages in matching
 *	document ought to be contribute to the rank.
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Keywords are :keyword, Result is :limit rows, offset :offset
\echo Text Search Configuration is :ts_conf
\echo

\x on
with pdf_page_match as (
  select
	tsv.pdf_blob as blob,
	min(tsv.tsv <=> q) as page_distance_min,
	count(tsv.pdf_blob)::float8 as match_page_count
  from
	pdfbox2.page_tsv_utf8 tsv,
	plainto_tsquery(:ts_conf, :keyword) as q
  where
  	tsv.tsv @@ q
	and
	tsv.ts_conf = :ts_conf::text
  group by
  	tsv.pdf_blob
  order by
  	page_distance_min asc,
	match_page_count desc
  limit
  	:limit
  offset
  	:offset
)
  select
  	pd.blob,
	match_page_count,
	pd.number_of_pages as pdf_page_count,
	page_distance_min,

	/*
	 *  For each matching pdf extract a headline of matching terms from
	 *  the page that is "closest" to the query.
	 */

	(with closest_page as (
	    select
		tsv.page_number,
		min(tsv.tsv <=> q) as page_distance
	    from
		pdfbox2.page_tsv_utf8 tsv,
		plainto_tsquery(:ts_conf, :keyword) as q
	    where
  		tsv.tsv @@ q
		and
		tsv.ts_conf = :ts_conf::text
		and
		tsv.pdf_blob = pd.blob
	    group by
	    	tsv.page_number
	    order by
	    	--  order by distance, then page number
	    	page_distance asc,
		page_number asc
	    limit
	    	1
	  ) select
	  	ts_headline(
			:ts_conf::regconfig,
			(select
				maxtxt.txt
			    from
			    	pdfbox2.page_text_utf8 maxtxt
			    where
			    	maxtxt.pdf_blob = pd.blob
				and
				maxtxt.page_number = near_tsv.page_number
			),
			q
		) || ' @ Page #' || near_tsv.page_number
	    from
	    	plainto_tsquery(:ts_conf, :keyword) as q,
		closest_page near_tsv
	) as "Snippet"
  from
  	pdfbox2.pddocument pd
	  join pdf_page_match pp on (pp.blob = pd.blob)
  group by
  	pd.blob,
	pp.page_distance_min,
	pp.match_page_count
  order by
  	pp.page_distance_min asc,
	match_page_count / pd.number_of_pages desc
;
