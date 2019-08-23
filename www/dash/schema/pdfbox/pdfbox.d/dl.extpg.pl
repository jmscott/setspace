#
#  Synopsis:
#	Generate an html <dl> of extracted utf8 pages in a pdf blob
#  Usage:
#	/cgi-bin/pdfbox?out=dl.extpg&blob=bc160:46036a9c2545b...
#
use utf8;

binmode(STDOUT, ":utf8");

require 'dbi-pg.pl';

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};

print <<END;
<dl$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $qh = dbi_pg_select(
	db =>		dbi_pg_connect(),
	tag =>		'select-dl-extpg',
	argv =>		[
				$blob
			],
	sql =>		q(
SELECT
	ep.page_number,
	pt.txt
  FROM
  	pdfbox.extract_pages_utf8 ep
	  JOIN pdfbox.page_text_utf8 pt ON (
	  	pt.pdf_blob = ep.pdf_blob
		AND
		pt.page_number = ep.page_number
	  )
  WHERE
  	ep.pdf_blob = $1
  ORDER BY
  	ep.page_number ASC
;
));

$blob = decode_url_query_arg($blob);
while (my $r = $qh->fetchrow_hashref()) {
	my $txt = encode_html_entities($r->{txt});
	print <<END;
 <dt>Page $r->{page_number}</dt>
 <dd>
  <a href="/schema/pdfbox/detail-tsv.shtml?blob=$blob">$txt</a>
 </dd>
END
}

print <<END;
</dl>
END
