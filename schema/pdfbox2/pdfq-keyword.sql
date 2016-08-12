/*
 *  Synopsis:
 *	Keyword query of PDF pages pages, sorting by relavence.
 *
 *  Command Line Variables:
 *	keyword		text
 *	limit		uint16
 *	offset		ubigint
 *	ts_conf		text
 *
 *  Usage:
 *	psql --set keyword="'$KEYWORDS'" --set limit=10 --set offset=0     \
 *		--file pdfq-keyword.sql
 *  Note:
 *	Unfortunately pddocument.number_of_pages == 0, so the weighted
 *	sort could (rarely) break.
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
	sum(tsv.tsv <=> q)::float8 as page_rank_sum,
	count(tsv.pdf_blob)::float8 as match_page_count
  from
	pdfbox2.page_tsv_utf8 tsv,
	plainto_tsquery(:ts_conf, :keyword) as q
  where
  	tsv.tsv @@ q
	and
	tsv.ts_conf = :ts_conf
  group by
  	1
  order by
  	page_rank_sum desc,
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
	/*
	 *  Note:
	 *	Unfortunately the schema allows number_of_pages == 0,
	 *	so this code could break!
	 */
  	max(page_rank_sum * (match_page_count / pd.number_of_pages)) as rank,

	--  headline for highest ranking page within the document

	(with max_ranked_tsv as (
	    select
	    	tsv.tsv <=> q,
		tsv.page_number
	    from
		pdfbox2.page_tsv_utf8 tsv,
		plainto_tsquery(:ts_conf, :keyword) as q
	    where
  		tsv.tsv @@ q
		and
		tsv.ts_conf = :ts_conf
		and
		tsv.pdf_blob = pd.blob
	    order by
	    	--  order by rank, then page number
	    	1 desc, 2 asc
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
				maxtxt.page_number = maxts.page_number
			),
			q
		) || ' @ Page #' || maxts.page_number
	    from
	    	plainto_tsquery(:ts_conf, :keyword) as q,
		max_ranked_tsv maxts
	) as "Snippet"
  from
  	pdfbox2.pddocument pd
	  join pdf_page_match pp on (pp.blob = pd.blob)
  group by
  	pd.blob,
	match_page_count
  order by
  	rank desc,
	match_page_count desc
;
