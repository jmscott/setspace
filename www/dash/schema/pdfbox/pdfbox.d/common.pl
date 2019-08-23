#
#  Synopsis:
#	Common routines for full text search.
#  Note:
#	Need to strip the english 'ago' verbage in discover_elapsed.
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
				$QUERY_ARG{offset},
			],
		sql =>	recent_sql()
	);
}

#
#  Find pdfs containing certain keywords.
#
#  Argument Vector:
#	$1	query keywords
#	$2	text search configuration (english, russian, etc)
#	$3	rank norm algorithm
#	$4	limit number of results returned
#	$5	start row offset
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
  	blob
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
		tag =>	'select-pdfbox-keyword',
		argv =>	[
			decode_url_query_arg($QUERY_ARG{q}),
			$QUERY_ARG{tsconf},
			$QUERY_ARG{rnorm},
			$QUERY_ARG{lim},
			$QUERY_ARG{offset},
		],
		sql =>	keyword_sql()
	);
}

#
#  Synopsis:
#	Phrase search across pdf pages, group by pdf, order by rank
#  Target List:
#	blob
#	discover_elapsed
#	match_page_count
#	number_of_pages
#	page_count
#	rank
#	snippet
#	title
#  Argument Vector:
#	$1	query keywords
#	$2	text search configuration (english, russian, etc)
#	$3	rank norm algorithm
#	$4	limit number of results returned
#	$5	start row offset
#
sub phrase_sql
{
	return q(
WITH pdf_page_match AS (
  SELECT
	tsv.pdf_blob AS blob,
	sum(ts_rank_cd(tsv.tsv, q, $3))::float8 AS page_rank_sum,
	count(tsv.pdf_blob)::float8 AS match_page_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	phraseto_tsquery($2, $1) AS q
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
		phraseto_tsquery($2, $1) AS q
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
	    	phraseto_tsquery($2, $1) AS q,
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
  	rank desc,
	match_page_count desc
	);
}

sub phrase_select
{
	return dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-pdfbox-phrase',
		# trace => 15,
		argv =>	[
			decode_url_query_arg($QUERY_ARG{q}),
			$QUERY_ARG{tsconf},
			$QUERY_ARG{rnorm},
			$QUERY_ARG{lim},
			$QUERY_ARG{offset},
		],
		sql =>	phrase_sql()
	);
}

#
#  Synopsis:
#	Full text search across pdf pages, group by pdf, order by rank
#  Target List:
#	blob
#	discover_elapsed
#	match_page_count
#	number_of_pages
#	page_count
#	rank
#	snippet
#	title
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
	    	--  order by rank, then page number
	    	1 desc, 2 asc
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
  	rank desc,
	match_page_count desc
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
#	discover_elapsed
#	match_page_count
#	number_of_pages
#	page_count
#	rank
#	snippet
#	title
#  Argument Vector:
#	$1	full text search syntax
#	$2	text search configuration (english, russian, etc)
#	$3	rank norm algorithm
#	$4	limit number of results returned
#	$5	start row offset
#
sub websearch_sql
{
	return q(
WITH pdf_page_match AS (
  SELECT
	tsv.pdf_blob AS blob,
	sum(ts_rank_cd(tsv.tsv, q, $3))::float8 AS page_rank_sum,
	count(tsv.pdf_blob)::float8 AS match_page_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	websearch_to_tsquery($2, $1) AS q
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
		websearch_to_tsquery($2, $1) AS q
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
	    	websearch_to_tsquery($2, $1) AS q,
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
  	rank desc,
	match_page_count desc
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

sub blob_sql
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
  WHERE
  	pdf.blob = $1
);}

sub blob_select
{
	my $blob = $QUERY_ARG{q};
	$blob =~ s/\s*//g;

	return dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-pdfbox-web',
		argv =>	[
			$blob
		],
		sql =>	blob_sql()
	);
}

1;
