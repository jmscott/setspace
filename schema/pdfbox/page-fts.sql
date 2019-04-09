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
 *	The headline fails for the pdfq query
 *
 *		pdfq page fts:'(partition <2> integers) & caching'
 *		for pdf blob sha:628414538bcb0963ef304dffbe7a00c940aa154d
 */
\timing on
\x on

\echo 
\echo Full text Query is :ts_query, Result is :limit rows, offset :offset
\echo Text Search Configuration is :ts_conf
\echo

\x on
WITH pdf_page_match AS (
  SELECT
	tsv.pdf_blob,
	sum(ts_rank_cd(tsv.tsv, q, :rank_norm))::float8 AS page_rank_sum,
	count(tsv.pdf_blob)::float8 AS match_page_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	to_tsquery(:ts_conf, :ts_query) AS q
  WHERE
  	tsv.tsv @@ q
	AND
	tsv.ts_conf = :ts_conf::text
  GROUP BY
  	1
  ORDER BY
  	page_rank_sum DESC,
	match_page_count DESC
  LIMIT
  	:limit
  OFFSET
  	:offset
)
  SELECT
  	pd.blob AS pdf_blob,
	match_page_count,
	pd.number_of_pages AS pdf_page_count,
	/*
	 *  Note:
	 *	Unfortunately the schema allows number_of_pages == 0,
	 *	so this code could break!
	 */
  	max(page_rank_sum * (match_page_count / pd.number_of_pages)) AS rank,

	/*
	 *  Extract a headline of matching terms from the highest ranking page
	 *  within a particular ranked pdf blob.
	 */

	(WITH max_ranked_tsv AS (
	    SELECT
	    	sum(ts_rank_cd(tsv.tsv, q, :rank_norm))::float8,
		tsv.page_number
	    FROM
		pdfbox.page_tsv_utf8 tsv,
		to_tsquery(:ts_conf, :ts_query) AS q
	    WHERE
  		tsv.tsv @@ q
		AND
		tsv.ts_conf = :ts_conf::text
		AND
		tsv.pdf_blob = pd.blob
	    GROUP BY
	    	tsv.page_number
	    ORDER BY
	    	--  order by rank, then page number
	    	1 desc, 2 asc
	    LIMIT
	    	1
	  ) SELECT
	  	ts_headline(
			:ts_conf::regconfig,
			(SELECT
				maxtxt.txt
			    FROM
			    	pdfbox.page_text_utf8 maxtxt
			    WHERE
			    	maxtxt.pdf_blob = pd.blob
				AND
				maxtxt.page_number = maxts.page_number
			),
			q
		) || ' @ Page #' || maxts.page_number
	    from
	    	to_tsquery(:ts_conf, :ts_query) AS q,
		max_ranked_tsv maxts
	) AS "match_headline"
  FROM
  	pdfbox.pddocument pd
	  JOIN pdf_page_match pp ON (pp.pdf_blob = pd.blob)
  GROUP BY
  	pd.blob,
	match_page_count
  ORDER BY
  	rank DESC,
	match_page_count DESC
;
