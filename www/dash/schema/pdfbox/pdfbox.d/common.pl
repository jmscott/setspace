#
#  Synopsis:
#	Common routines for full text search.
#  Note:
#	-  Duplicates in search across pages for
#
#		"surreal numbers"
#
#	The pdf
#
#		sha:03ca67996ca3b180fc395831194195646d7c2adc
#
#	appears on the second page and again on the sixth page.
#	Also try "Chinmayananda", duplicates are #30 and #31 in search
#	result.
#
#       -  For web search substitute | with OR amd ! WITH -
#
#	-  no matching page count for search
#
#		voodoo vector
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
	  	myt.title IS NOT NULL
	  THEN
	  	myt.title
	  ELSE
		pi.title
	END AS title,
	myt.title IS NULL AS mytitle_is_null,
	EXTRACT(epoch FROM s.discover_time) AS discover_epoch
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
#	discover_epoch
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
				$QUERY_ARG{offset},
			],
		sql =>	recent_sql()
	);
}

#
#  Synopsis:
#	Full text search across pdf pages, group by pdf, order by rank
#  Target List:
#	blob
#	discover_epoch
#	match_page_count
#	number_of_pages
#	page_count
#	rank
#	snippet
#	title
#	mytitle_is_null
#  Argument Vector:
#	$1	full text search syntax
#	$2	text search configuration (english, russian, etc)
#	$3	rank norm algorithm
#	$4	limit number of results returned
#	$5	start row offset
#
sub fts_sql
{
	return q(
WITH pdf_page_match AS (
  SELECT
	tsv.pdf_blob AS blob,
	sum(ts_rank_cd(tsv.tsv, q, $3))::float8 AS page_rank_sum,
	count(tsv.pdf_blob)::float8 AS match_page_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	to_tsquery($2, $1) AS q
  WHERE
  	tsv.tsv @@ q
	AND
	tsv.ts_conf = $2::regconfig
  GROUP BY
  	1
  ORDER BY
  	page_rank_sum DESC,
	match_page_count DESC
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
		to_tsquery($2, $1) AS q
	    WHERE
  		tsv.tsv @@ q
		AND
		tsv.ts_conf = $2::regconfig
		AND
		tsv.pdf_blob = pd.blob
	    GROUP BY
	    	tsv.page_number
	    ORDER BY
	    	1 DESC,		--  rank
		2 ASC		--  page number
	    LIMIT
	    	1
	  ) SELECT
	  	ts_headline(
			$2::regconfig,
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
	    	to_tsquery($2, $1) AS q,
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
	EXTRACT(epoch FROM s.discover_time) AS discover_epoch
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
	match_page_count DESC
	);
}

sub fts_select
{
	return dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-pdfbox-fts',
		argv =>	[
			decode_url_query_arg($QUERY_ARG{q}),
			$QUERY_ARG{tsconf},
			$QUERY_ARG{rnorm},
			$QUERY_ARG{lim},
			$QUERY_ARG{offset},
		],
		sql =>	fts_sql()
	);
}

#
#  Synopsis:
#	Typical websearch style query string: keyword/"phrase"/&|!
#  Target List:
#	blob
#	match_page_count
#	number_of_pages
#	page_count
#	rank
#	snippet
#	title,
#	mytitle_is_null
#	discover_epoch
#  Argument Vector:
#	$1	full text search syntax
#	$2	text search configuration (english, russian, etc)
#	$3	rank norm algorithm code: [1-14], see pg docs
#	$4	limit number of results returned
#	$5	start row offset
#
sub websearch_sql
{
	return q(
/*
 *  CTE mytitle_match:
 *	Find the pdfs for which the title ranking is the highest.
 */
WITH mytitle_match AS (
  SELECT
  	tsv.blob AS blob,
	ts_rank_cd(tsv.tsv, q, $3)::float8 AS rank
    FROM
    	mycore.title_tsv tsv,
	websearch_to_tsquery($2, $1) AS q
    WHERE
    	tsv.tsv @@ q
	AND
	tsv.ts_conf = $2::regconfig
    ORDER BY
  	rank DESC
    LIMIT
  	$4
    OFFSET
  	$5
),
/*
 *  CTE page_match:
 *	Find the pdfs for which the sum of the ranks on the matching pages is
 *	highest.
 */
page_match AS (
  SELECT
	tsv.pdf_blob AS blob,
	sum(ts_rank_cd(tsv.tsv, q, $3))::float8 AS rank,
	count(tsv.pdf_blob)::float8 AS match_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	websearch_to_tsquery($2, $1) AS q
  WHERE
  	tsv.tsv @@ q
	AND
	tsv.ts_conf = $2::regconfig
  GROUP BY
  	tsv.pdf_blob
  ORDER BY
  	rank DESC,
	match_count DESC
  LIMIT
  	$4
  OFFSET
  	$5
), merge_pdf AS (
  /*
   *  Merge matching pdfs to eliminate duplicate matches across both title
   *  and pages.  This set may be less than 2 * limit elements, since sometimes
   *  both the title and pages are in the top 10 of their respecitve match sets.
   */
  SELECT
  	blob
    FROM
    	mytitle_match
  UNION
  SELECT
  	blob
    FROM
    	page_match
), merge_ranked AS (
  SELECT
  	pdf.blob,
	mtm.rank AS mytitle_rank,
	pm.rank AS page_rank,
	greatest(mtm.rank, pm.rank) AS greatest_rank,
	pm.match_count AS match_page_count
    FROM
    	merge_pdf pdf
	  LEFT OUTER JOIN mytitle_match mtm ON (mtm.blob = pdf.blob)
	  LEFT OUTER JOIN page_match pm ON (pm.blob = pdf.blob)
) SELECT
	mr.blob,
	mr.match_page_count,
	/*
	 *  Assemble the snippet
	 */
	(WITH max_ranked_tsv AS (
	    SELECT
	    	sum(ts_rank_cd(tsv.tsv, q, $3))::float8,
		tsv.page_number
	    FROM
		pdfbox.page_tsv_utf8 tsv,
		websearch_to_tsquery($2, $1) AS q
	    WHERE
  		tsv.tsv @@ q
		AND
		tsv.ts_conf = $2::regconfig
		AND
		tsv.pdf_blob = mr.blob
	    GROUP BY
	    	tsv.page_number
	    ORDER BY
	    	1 DESC,		--  rank
		2 ASC		--  page number
	    LIMIT
	    	1
	  ) SELECT
	  	ts_headline(
			$2::regconfig,
			(SELECT
				maxtxt.txt
			    FROM
			    	pdfbox.page_text_utf8 maxtxt
			    WHERE
			    	maxtxt.pdf_blob = mr.blob
				AND
				maxtxt.page_number = maxts.page_number
			),
			q
		) || ' @ Page #' || maxts.page_number
	    FROM
	    	websearch_to_tsquery($2, $1) AS q,
		max_ranked_tsv maxts
	) AS snippet,
	CASE
	  WHEN
	  	myt.title IS NOT NULL
	  THEN
	  	myt.title
	  ELSE
		pi.title
	END AS title,
	myt.title IS NULL AS mytitle_is_null,
	pd.number_of_pages,
	EXTRACT(epoch FROM s.discover_time) AS discover_epoch
    FROM
    	merge_ranked mr
	  JOIN pdfbox.pddocument_information pi ON (
	  	pi.blob = mr.blob
	  )
	  JOIN pdfbox.pddocument pd ON (
	  	pd.blob = mr.blob
	  )
	  JOIN setcore.service s ON (s.blob = mr.blob)
	  LEFT OUTER JOIN mycore.title myt ON (myt.blob = mr.blob)
    ORDER BY
    	greatest_rank DESC,
	pd.number_of_pages ASC,
	/*
	 *  Note:
	 *	Removing the order by discover_time makes the search
	 *	about twices as quick on "Chinmayananda".  why?
	 */
	s.discover_time DESC
    LIMIT
    	$4
;
	);
}

sub websearch_select
{
	return dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-pdfbox-web',
		argv =>	[
			decode_url_query_arg($QUERY_ARG{q}),
			$QUERY_ARG{tsconf},
			$QUERY_ARG{rnorm},
			$QUERY_ARG{lim},
			$QUERY_ARG{offset},
		],
		sql =>	websearch_sql()
	);
}

sub sql_pdf_blob
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
	myt.title IS NULL AS mytitle_is_null,
	EXTRACT(epoch FROM s.discover_time) AS discover_epoch
  FROM
  	pdfbox.pddocument pdf JOIN setcore.service s ON (s.blob = pdf.blob)
	  LEFT OUTER JOIN mycore.title myt ON (myt.blob = pdf.blob)
	  LEFT OUTER JOIN pdfbox.pddocument_information pi ON (
	  	pi.blob = pdf.blob
	  )
  WHERE
  	pdf.blob = $1
);}

sub select_pdf_blob
{
	my $blob = $QUERY_ARG{q};
	$blob =~ s/\s*//g;

	return dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-pdfbox-web',
		argv =>	[
			$blob
		],
		sql =>	sql_pdf_blob()
	);
}
