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
WITH pdf_page_match AS (
  SELECT
	tsv.pdf_blob AS blob,
	min(tsv.tsv <=> q) AS page_distance_min,
	count(tsv.pdf_blob)::float8 AS match_page_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	plainto_tsquery(:ts_conf, :keyword) AS q
  WHERE
  	tsv.tsv @@ q
	AND
	tsv.ts_conf = :ts_conf::regconfig
  GROUP BY
  	tsv.pdf_blob
  ORDER BY
  	page_distance_min ASC,
	match_page_count DESC
  LIMIT
  	:limit
  OFFSET
  	:offset
)
  SELECT
  	pd.blob,
	match_page_count,
	pd.number_of_pages as pdf_page_count,
	page_distance_min,

	/*
	 *  For each matching pdf extract a headline of matching terms from
	 *  the page that is "closest" to the query.
	 */

	(WITH closest_page AS (
	    SELECT
		tsv.page_number,
		min(tsv.tsv <=> q) AS page_distance
	      FROM
		pdfbox.page_tsv_utf8 tsv,
		plainto_tsquery(:ts_conf, :keyword) as q
	      where
  		tsv.tsv @@ q
		AND
		tsv.ts_conf = :ts_conf::regconfig
		AND
		tsv.pdf_blob = pd.blob
	    GROUP BY
	    	tsv.page_number
	    ORDER BY
	    	--  order by distance, then page number
	    	page_distance ASC,
		page_number ASC
	    LIMIT
	    	1
	  ) SELECT
	  	ts_headline(
			:ts_conf,
			(SELECT
				maxtxt.txt
			    FROM
			    	pdfbox.page_text_utf8 maxtxt
			    WHERE
			    	maxtxt.pdf_blob = pd.blob
				AND
				maxtxt.page_number = near_tsv.page_number
			),
			q
		) || ' @ Page #' || near_tsv.page_number
	    from
	    	plainto_tsquery(:ts_conf, :keyword) AS q,
		closest_page near_tsv
	) AS "Snippet"
  FROM
  	pdfbox.pddocument pd
	  JOIN pdf_page_match pp ON (pp.blob = pd.blob)
  GROUP BY
  	pd.blob,
	pp.page_distance_min,
	pp.match_page_count
  ORDER BY
  	pp.page_distance_min ASC,
	match_page_count / pd.number_of_pages desc
;
