#
#  Synopsis:
#	Write html <dl> of pdf documents that match keywrod search.
#  Usage:
#	/cgi-bin/pdfbox?out=dl&q=neural+cryptography
#

require 'dbi-pg.pl';
require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $q =		decode_url_query_arg($QUERY_ARG{q});
my $ts_conf =	$QUERY_ARG{tsconf};
my $rank_norm = $QUERY_ARG{rnorm};
my $limit =	$QUERY_ARG{lim};
my $offset =	$QUERY_ARG{off};

print <<END;
<table $QUERY_ARG{id_att}$QUERY_ARG{class_att}>
 <thead>
END

unless ($q =~ m/[[:graph:]]/) {
	print <<END;
  <caption>No Query Specified</caption>
 </thead>
</table>
END
	exit;
}

my $qh = dbi_pg_select(
	db =>	dbi_pg_connect(),
	tag =>	'select-pdfbox-page-dl',
	argv =>	[
			$q,
			$ts_conf,
			$rank_norm,
			$limit,
			$offset
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
	) AS "snippet",
	myt.title,
	pi.title AS pdf_title
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

#  Note: write execution speed.
print <<END;
  <caption>Query: $q</caption>
  <tr>
   <th>PDF Blob</th>
   <th>Rank</th>
   <th>Match Page Count</th>
   <th>PDF Page Count</th>
   <th>Title</th>
   <th>Snippet</th>
  </tr>
 </thead>
 <tbody>
END

while (my $r = $qh->fetchrow_hashref()) {
	my $pdf_blob = encode_html_entities($r->{pdf_blob});
	my $rank = encode_html_entities($r->{rank});
	my $match_page_count = encode_html_entities($r->{match_page_count});
	my $pdf_page_count = encode_html_entities($r->{pdf_page_count});
	my $snippet = encode_html_entities($r->{snippet});
	my $title = 'title';
	$title = 'pdf_title' unless length($r->{title}) > 0;
	$title = encode_html_entities($r->{$title});
	print <<END;
 <tr>
  <td>$pdf_blob</td>
  <td>$rank</td>
  <td>$match_page_count</td>
  <td>$pdf_page_count</td>
  <td>$title</td>
  <td>$snippet</td>
 </tr>
END
}

print <<END;
 </tbody>
</table>
END
