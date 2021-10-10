#
#  Synopsis:
#	Write html <table> of pdf documents that match full text search.
#  Usage:
#	/cgi-bin/schema/pdfbox?out=table&q=neural+cryptography
#	/cgi-bin/schema/pdfbox?out=table&q=neural+cryptography&off=10
#  Note:
#	httpd2.d/common.pl ought to be references as
#
#		jmscptt/httpd2.d/common.pl
#
#	The snippet is not escaped properly.  Need to escape match indicators
#	<b> with a random string and the transform to <span class="key">.
#
use Time::HiRes qw(gettimeofday);

require 'httpd2.d/common.pl';

require 'dbi-pg.pl';
require 'schema/pdfbox.d/common.pl';

our %QUERY_ARG;

my $q = $QUERY_ARG{q};

print <<END;
<table$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
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

#  run the keyword query
my $start_time = gettimeofday();
my $qh = keyword_select();
my $end_time = gettimeofday();
my $elapsed_sec = sprintf('%.1fs', gettimeofday() - $start_time);

#  Write the <tbody> <caption> and <th> elements

print <<END;
  <caption>Query: $q ($elapsed_sec)</caption>
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

#  Write the matching pdf blobs <tr>

while (my $r = $qh->fetchrow_hashref()) {
	my $pdf_blob = encode_html_entities($r->{pdf_blob});
	my $rank = encode_html_entities($r->{rank});
	my $match_page_count = encode_html_entities($r->{match_page_count});
	my $pdf_page_count = encode_html_entities($r->{pdf_page_count});
	my $snippet = $r->{snippet};
	my $title = 'title';
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

1;
