/*
 *  Synopsis:
 *	Full text search across pdf only pages, grouped by pdf, order by rank
 *
 *  Command Line Variables:
 *	ts_query	text
 *	limit		uint16
 *	offset		ubigint
 *	ts_conf		text
 *	rank_norm	uint32
 *
 *  Usage:
 *	psql								\
 *	  --var ts_query="'(suffix | spanning) <-> tree'"		\
 *	  --var limit=10						\
 *	  --var offset=0						\
 *	  --var rank_norm=14						\
 *	  --file page-text-utf8-fts.sql
 *
 *  Note:
 *	Unfortunately pddocument.number_of_pages == 0 is allowed, so the
 *	weighted sort could (rarely) break.
 */
\timing on
\x on

\echo 
\echo Full text Query is :ts_query, Result is :limit rows, offset :offset
\echo Text Search Configuration is :ts_conf
\echo

\x on
with pdf_page_match as (
  select
	tsv.pdf_blob as blob,
	sum(ts_rank_cd(tsv.tsv, q, :rank_norm))::float8 as page_rank_sum,
	count(tsv.pdf_blob)::float8 as match_page_count
  from
	pdfbox2.page_tsv_utf8 tsv,
	to_tsquery(:ts_conf, :ts_query) as q
  where
  	tsv.tsv @@ q
	and
	tsv.ts_conf = :ts_conf::text
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

	/*
	 *  Extract a headline of matching terms from the highest ranking page
	 *  within a particular ranked pdf blob.
	 */

	(with max_ranked_tsv as (
	    select
	    	sum(ts_rank_cd(tsv.tsv, q, :rank_norm))::float8,
		tsv.page_number
	    from
		pdfbox2.page_tsv_utf8 tsv,
		to_tsquery(:ts_conf, :ts_query) as q
	    where
  		tsv.tsv @@ q
		and
		tsv.ts_conf = :ts_conf::text
		and
		tsv.pdf_blob = pd.blob
	    group by
	    	tsv.page_number
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
	    	to_tsquery('english', :ts_query) as q,
		max_ranked_tsv maxts
	) as "match_headline"
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
