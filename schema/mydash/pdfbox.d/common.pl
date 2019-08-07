#
#  Synopsis:
#	Common routines for full text search.
#

use utf8;

our %QUERY_ARG;

sub recent_sql
{
	return q(
SELECT
	pdf.blob,
	pdf.number_of_pages,
	CASE
	  WHEN
	  	myt.title ~ '[[:graph:]]'
	  THEN
	  	myt.title
	  ELSE
		pi.title
	END AS title,
	regexp_replace(age(now(), s.discover_time)::text, '\..*', '') || ' ago'
		AS discover_elapsed
  FROM
  	pdfbox.pddocument pdf JOIN setcore.service s ON (s.blob = pdf.blob)
	  LEFT OUTER JOIN mycore.title myt ON (myt.blob = pdf.blob)
	  LEFT OUTER JOIN pdfbox.pddocument_information pi ON (
	  	pi.blob = pdf.blob
	  )
  ORDER BY
  	s.discover_time DESC
  LIMIT
  	$1
  OFFSET
  	$2
);}

#
#  Return recent pdf's, sorted by discover_time descending.
#
#  Target List:
#	blob,
#	discover_elapsed
#	number_of_pages
#	title
#
sub recent_select
{
	return dbi_pg_select(
		db =>   dbi_pg_connect(),
		tag =>  'pdfbox-recent_select',
		argv =>	[
				$QUERY_ARG{lim},
				$QUERY_ARG{off},
			],
		sql =>	recent_sql()
	);
}

#
#  Find pdfs containing certain keywords.
#
#  Target List:
#	blob
#	discover_elapsed
#	match_page_count
#	number_of_pages
#	page_count
#	rank
#	snippet
#	title
#
sub keyword_sql
{
	return q(
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
  	pd.blob,
	match_page_count,
	pd.number_of_pages,
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
	END AS title,
	regexp_replace(age(now(), s.discover_time)::text, '\..*', '') || ' ago'
		AS discover_elapsed
  FROM
  	pdf_page_match pp
	  JOIN setcore.service s ON (s.blob = pp.blob)
	  JOIN pdfbox.pddocument pd ON (pd.blob = pp.blob)
	  LEFT OUTER JOIN mycore.title myt ON (myt.blob = pp.blob)
	  LEFT OUTER JOIN pdfbox.pddocument_information pi ON (pi.blob = pp.blob)
  GROUP BY
  	pd.blob,
	match_page_count,
	myt.title,
	pi.title,
	s.discover_time
  ORDER BY
  	rank DESC,
	s.discover_time,
	match_page_count DESC
;
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
		sql =>	keyword_sql()
	);
}

1;
