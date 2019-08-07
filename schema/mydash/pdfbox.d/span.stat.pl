#
#  Synopsis:
#	Write html <span> of query stats.
#  Note:
#	One day this query may be a materialized view.
#

require 'dbi-pg.pl';

our %QUERY_ARG;

my $q = $QUERY_ARG{q};
my $sql;

my $qh = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-span-stat',
		sql => q(
SELECT
	count(pd.*) AS pdf_count,
	sum(pd.number_of_pages) AS pdf_page_count,
	pg_size_pretty(sum(bc.byte_count)) AS pdf_byte_count
  FROM
  	pdfbox.pddocument pd
	  JOIN setcore.byte_count bc ON (bc.blob = pd.blob)
;
));

my $r = $qh->fetchrow_hashref();
print <<END;
<span
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>$r->{pdf_count} pdfs,
 $r->{pdf_page_count} pages,
 $r->{pdf_byte_count}</span>
END
