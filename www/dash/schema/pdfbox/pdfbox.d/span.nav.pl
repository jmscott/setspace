#
#  Synopsis:
#	Write html <span> of for navigating search results
#  Note:
#	no reverse arrow exists for this url.
#
#		/schema/pdfbox/index.shtml?q=Mazurkiewicz%20traces&offset=60&imit=100

#	The page count should link to the final search page.
#
#	Remove qtype="" from url.
#
#	Consider pretty printing using use POSIX qw(locale_h)
#	instead of english style 999,999.
#
#	One day this query may be a materialized view.
#

use utf8;

#  stop apache log message 'Wide character in print at ...' from arrow chars
binmode(STDOUT, ":utf8");

require 'dbi-pg.pl';
require 'pdfbox.d/common.pl';

our %QUERY_ARG;

my $q = $QUERY_ARG{q};
my $offset = $QUERY_ARG{offset};
my $qtype = $QUERY_ARG{qtype};
my ($sql, $argv);
my $limit = $QUERY_ARG{limit};

if ($q =~ m/^\s*[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}\s*$/) {
	my $blob = $q;
	$blob =~ s/\s*//g;
	$argv = [
		$blob
	];
	$sql = q(
SELECT
	count(pd.blob) AS pdf_count,
	CASE
	  WHEN
	  	sum(pd.number_of_pages) IS NULL
	  THEN
	  	0
	  ELSE
	  	sum(pd.number_of_pages)
	END AS pdf_page_count
  FROM
  	pdfbox.pddocument pd
  WHERE
  	pd.blob = $1
;);
} elsif ($q =~ m/[[:graph:]]/) {
	$argv = [
		$q,
		'english'
	];
	my $to_tsquery = 'websearch_to_tsquery';

	if ($qtype eq 'phrase') {
		$to_tsquery = 'phraseto_tsquery'; 
	} elsif ($qtype eq 'fts') {
		$to_tsquery = 'to_tsquery';
	} elsif ($qtype eq 'key') {
		$to_tsquery = 'plainto_tsquery';
	}

	#  Note:  why not use q()?
	$sql =<<END;
SELECT
	count(DISTINCT tsv.pdf_blob) AS pdf_count,
	count(tsv.pdf_blob)::float8 AS pdf_page_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	$to_tsquery(\$2, \$1) AS q
  WHERE
  	tsv.tsv @@ q
	AND
	tsv.ts_conf = \$2::regconfig
;
END
	;
} else {
	$sql = q(
SELECT
	count(pd.*) AS pdf_count,
	sum(pd.number_of_pages) AS pdf_page_count
  FROM
  	pdfbox.pddocument pd
;);
}

my $r = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-span-stat',
		argv =>	$argv,
		sql => $sql
)->fetchrow_hashref();

my $pdf_count = $r->{pdf_count};
my $pdf_page_count = $r->{pdf_page_count};

print <<END;
<span
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>
END

if ($pdf_count == 0) {
	print <<END;
No pdf documents.</span>
END
	return 1;
}

if ($pdf_count <= $limit) {
	my $plural = 's';
	my $page_plural = 's';
	$plural = '' if $pdf_count == 1;
	$page_plural = '' if $pdf_page_count == 1;

	print <<END;
$pdf_count doc$plural and $pdf_page_count page$page_plural matched
END
	return 1;
}

my $arrow_off;
$q = encode_url_query_arg($q);
if ($offset >= $limit) {
	$arrow_off = $offset - $limit;
	print <<END;
<a href="/schema/pdfbox/index.shtml?q=$q&offset=$arrow_off&qtype=$qtype&limit=$limit">◀</a>
END
}

my $doc_lower = $offset + 1;
my $doc_up = $doc_lower + $limit - 1;
$doc_up = $pdf_count if $doc_up > $pdf_count;

#  Note:
#	Rewrite with commas, english style.
#	Need a library here.
#
1 while $doc_lower =~ s/^(\d+)(\d{3})/$1,$2/;
1 while $doc_up =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
$doc_lower to $doc_up
END

$arrow_off = $offset + $limit;
print <<END if $arrow_off < $pdf_count;
<a href="/schema/pdfbox/index.shtml?q=$q&offset=$arrow_off&qtype=$qtype&limit=$limit">▶</a>
END

#  add commas to numbers to render human readable
1 while $pdf_count =~ s/^(\d+)(\d{3})/$1,$2/;
1 while $pdf_page_count =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
of $pdf_count docs and $pdf_page_count pages matched
</span>
END

1;
