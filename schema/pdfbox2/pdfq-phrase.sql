/*
 *  Synopsis:
 *	Phrase query of PDF pages pages, sorting by relavence and matched pages.
 *
 *  Command Line Variables:
 *	phrase		text
 *	limit		uint16
 *	offset		ubigint
 *	ts_conf		text
 *
 *  Usage:
 *	psql --set keywords="'$KEYWORDS'" --set limit=10 --set offset=0     \
 *		--file keyword.sql
 *  Note:
 *	Unfortunately pddocument.number_of_pages == 0, so the weighted
 *	sort could (rarely) break.
 */
\set ON_ERROR_STOP on
\timing on

\echo 
\echo Phrase is :phrase, Result is :limit rows, offset :offset
\echo Text Search Configuration is :ts_conf
\echo

with pdf_page_match as (
  select
	tsv.pdf_blob as blob,
	sum(tsv.tsv <=> q)::float8 as page_rank_sum,
	count(tsv.pdf_blob)::float8 as match_page_count
  from
	pdfbox2.page_tsv_utf8 tsv,
	phraseto_tsquery(:ts_conf, :phrase) as q
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
	 *	so this code could (rarely) break!
	 */
  	max(page_rank_sum * (match_page_count / pd.number_of_pages)) as rank,

	--  headline for highest ranking page within the document

	(with max_ranked_tsv_per_pdf as (
	    select
	    	tsv.tsv <=> q as page_rank,
		tsv.page_number
	    from
		pdfbox2.page_tsv_utf8 tsv,
		phraseto_tsquery(:ts_conf, :phrase) as q
	    where
  		tsv.tsv @@ q
		and
		tsv.ts_conf = :ts_conf::text
		and
		tsv.pdf_blob = pd.blob
	    order by
	    	page_rank desc,
		page_number asc
	    limit
	    	1
	  ) select
	  	ts_headline(
			:ts_conf,
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
	    	phraseto_tsquery(:ts_conf, :phrase) as q,
		max_ranked_tsv_per_pdf maxts
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
