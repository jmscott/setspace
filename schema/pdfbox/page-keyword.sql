/*
 *  Synopsis:
 *	Keyword search across pdf only pages, group by pdf, order by rank
 *
 *  Command Line Variables:
 *	keyword		text
 *	limit		uint16
 *	offset		ubigint
 *	ts_conf		text
 *	rank_norm	uint32
 *
 *  Usage:
 *	psql								\
 *	  --var keywords="'$KEYWORDS'"					\
 *	  --var limit=10						\
 *	  --var offset=0						\
 *	  --var rank_norm=14						\
 *	  --file page-text-utf8-keyword.sql
 *  Note:
 *	Unfortunately pddocument.number_of_pages == 0 is allowed, so the
 *	weighted sort could (rarely) break.
 */
\set ON_ERROR_STOP on
\timing on
\x on

\echo 
\echo Keywords are :keyword, Result is :limit rows, offset :offset
\echo Text Search Configuration is :ts_conf
\echo

\x on
WITH pdf_page_match AS (
  SELECT
	tsv.pdf_blob AS blob,
	sum(ts_rank_cd(tsv.tsv, q, :rank_norm))::float8 AS page_rank_sum,
	count(tsv.pdf_blob)::float8 AS match_page_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	plainto_tsquery(:ts_conf, :keyword) AS q
  WHERE
  	tsv.tsv @@ q
	AND
	tsv.ts_conf = :ts_conf::text
  GROUP BY
  	1
  ORDER BY
  	page_rank_sum desc,
	match_page_count desc
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
		plainto_tsquery(:ts_conf, :keyword) AS q
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
	    FROM
	    	plainto_tsquery(:ts_conf, :keyword) AS q,
		max_ranked_tsv maxts
	) AS "Snippet"
  FROM
  	pdfbox.pddocument pd
	  JOIN pdf_page_match pp ON (pp.blob = pd.blob)
  GROUP BY
  	pd.blob,
	match_page_count
  ORDER BY
  	rank DESC,
	match_page_count DESC
;
