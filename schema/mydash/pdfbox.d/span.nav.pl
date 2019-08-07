#
#  Synopsis:
#	Write html <span> of for navigating search results
#  Note:
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

if ($q =~ /[[:graph:]]/) {
	$argv = [
		$q,
		'english'
	];
	$sql = q(
SELECT
	count(DISTINCT tsv.pdf_blob) AS pdf_count,
	count(tsv.pdf_blob)::float8 AS pdf_page_count
  FROM
	pdfbox.page_tsv_utf8 tsv,
	plainto_tsquery($2, $1) AS q
  WHERE
  	tsv.tsv @@ q
	AND
	tsv.ts_conf = $2::regconfig
;
	)
} else {
	$sql = q(
SELECT
	count(pd.*) AS pdf_count,
	sum(pd.number_of_pages) AS pdf_page_count
  FROM
  	pdfbox.pddocument pd
	  JOIN setcore.byte_count bc ON (bc.blob = pd.blob)
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

my $arrow_off;
if ($offset >= 10) {
	$arrow_off = $offset - 10;
	print <<END;
<a href="/pdfbox.shtml?q=$q&offset=$arrow_off&qtype=$qtype">◀</a>
END
}

print <<END;
$pdf_count docs, $pdf_page_count pages
END

$arrow_off = $offset + 10;
print <<END if $arrow_off < $pdf_count;
<a href="/pdfbox.shtml?q=$q&offset=$arrow_off&qtype=$qtype">▶</a>
END

print <<END;
</span>
END
