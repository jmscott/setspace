#
#  Synopsis:
#	Write html <span> of for navigating search results
#  Note:
#	One day this query may be a materialized view.
#

use utf8;

require 'dbi-pg.pl';

our %QUERY_ARG;

my $q = $QUERY_ARG{q};
my $off = $QUERY_ARG{off};

my $r = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-span-stat',
		sql => q(
SELECT
	count(pd.*) AS pdf_count,
	sum(pd.number_of_pages) AS pdf_page_count
  FROM
  	pdfbox.pddocument pd
	  JOIN setcore.byte_count bc ON (bc.blob = pd.blob)
;
))->fetchrow_hashref();

my $pdf_count = $r->{pdf_count};
my $pdf_page_count = $r->{pdf_page_count};

print <<END;
<span
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>
END

my $arrow_off;
if ($off >= 10) {
	$arrow_off = $off - 10;
	print <<END;
<a href="/pdfbox.shtml?q=$q&off=$arrow_off">◀</a>
END
}

print <<END;
$pdf_count docs, $pdf_page_count pages
END

$arrow_off = $off + 10;
print <<END if $arrow_off < $pdf_count;
<a href="/pdfbox.shtml?q=$q&off=$arrow_off">▶</a>
END

print <<END;
</span>
END
