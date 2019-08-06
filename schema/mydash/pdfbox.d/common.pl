#
#  Synopsis:
#	Common routines for full text search.
#

our %QUERY_ARG;

sub recent_select
{
	return dbi_pg_select(
		db =>   dbi_pg_connect(),
		tag =>  'pdfbox-recent_select',
		argv =>	[
				$QUERY_ARG{lim},
				$QUERY_ARG{off},
			],
		sql =>	q(
		)
	);
}

sub keyword_select
{
	return dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'pdfbox-keyword_select',
		argv =>	[
				decode_url_query_arg($QUERY_ARG{q}),
				$QUERY_ARG{tsconf},
				$QUERY_ARG{rnorm},
				$QUERY_ARG{lim},
				$QUERY_ARG{off},
			],
		sql =>	q(
WITH pdf_page_match AS (
  SELECT
	tsv.pdf_blob AS blob,
	sum(ts_rank_cd(tsv.tsv, q, $3))::float8 AS page_rank_sum,
	count(tsv.pdf_blob)::float8 AS match_page_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	plainto_tsquery($2, $1) AS q
  WHERE
  	tsv.tsv @@ q
	AND
	tsv.ts_conf = $2::regconfig
  GROUP BY
  	1
  ORDER BY
  	page_rank_sum desc,
	match_page_count desc
  LIMIT
  	$4
  OFFSET
  	$5
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
	    	sum(ts_rank_cd(tsv.tsv, q, $3))::float8,
		tsv.page_number
	      FROM
		pdfbox.page_tsv_utf8 tsv,
		plainto_tsquery($2, $1) AS q
	      WHERE
  		tsv.tsv @@ q
		AND
		tsv.ts_conf = $2::regconfig
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
			$2,
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
	    	plainto_tsquery($2, $1) AS q,
		max_ranked_tsv maxts
	) AS snippet,
	CASE
	  WHEN
		length(myt.title) > 0
	  THEN
	  	myt.title
	  ELSE
		pi.title
	END AS title
  FROM
  	pdf_page_match pp
	  JOIN pdfbox.pddocument pd ON (pd.blob = pp.blob)
	  LEFT OUTER JOIN mycore.title myt ON (myt.blob = pp.blob)
	  LEFT OUTER JOIN pdfbox.pddocument_information pi ON (pi.blob = pp.blob)
  GROUP BY
  	pd.blob,
	match_page_count,
	myt.title,
	pi.title
  ORDER BY
  	rank DESC,
	match_page_count DESC
;
	));
}

1;
