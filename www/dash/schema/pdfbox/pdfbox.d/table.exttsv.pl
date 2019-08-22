#
#  Synopsis:
#	Generate an html <dl> of extracted utf8 pages in a pdf blob
#  Usage:
#	/cgi-bin/pdfbox?out=dl.extpg&blob=bc160:46036a9c2545b...
#  Note:
#	Added page number to detail!
#
use utf8;

binmode(STDOUT, ":utf8");

require 'dbi-pg.pl';

our %QUERY_ARG;

print <<END;
<table$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
 <thead>
  <tr>
   <th>Page</th>
   <th>UTF8 Text</th>
   <th>Text Search Vector</th>
   <th>Text Search Config</th>
  </tr>
 </thead>
 <tbody>
END

my $qh = dbi_pg_select(
	db =>		dbi_pg_connect(),
	tag =>		'select-dl-extpg',
	argv =>		[
				$QUERY_ARG{blob}
			],
	sql =>		q(
SELECT
	ep.page_number,
	pt.txt,
	tsv.ts_conf::text,
	tsv.tsv::text
  FROM
  	pdfbox.extract_pages_utf8 ep
	  JOIN pdfbox.page_text_utf8 pt ON (
	  	pt.pdf_blob = ep.pdf_blob
		AND
		pt.page_number = ep.page_number
	  )
	  JOIN pdfbox.page_tsv_utf8 tsv ON (
	  	tsv.pdf_blob = ep.pdf_blob
		AND
		tsv.page_number = ep.page_number
	  )
  WHERE
  	ep.pdf_blob = $1
  ORDER BY
  	ep.page_number ASC,
	tsv.ts_conf ASC
;
;
));

while (my $r = $qh->fetchrow_hashref()) {
	my $page_number = encode_html_entities($r->{page_number});
	my $txt = encode_html_entities($r->{txt});
	my $tsv = encode_html_entities($r->{tsv});
	my $ts_conf = encode_html_entities($r->{ts_conf});
	print <<END;
  <tr>
   <td>$page_number</td>
   <td>$txt</td>
   <td>$tsv</td>
   <td>$ts_conf</td>
  </tr>
END
}

print <<END;
 </tbody>
</table>
END
