#
#  Synopsis:
#	Write html <table> of all setcore attributes.
#  Usage:
#	/cgi-bin/setcore?out=table
#
use Time::HiRes qw(gettimeofday);

require 'dbi-pg.pl';
require 'httpd2.d/common.pl';
require 'setcore.d/common.pl';

our %QUERY_ARG;

my $q = $QUERY_ARG{q};

print <<END;
<table$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
 <thead>
END

#  run the keyword query
my $start_time = gettimeofday();
my $qh = recent_select();
my $end_time = gettimeofday();
my $elapsed_sec = sprintf('%.1fs', gettimeofday() - $start_time);

#  Write the <tbody> <caption> and <th> elements

print <<END;
  <caption>Query: $q ($elapsed_sec)</caption>
  <tr>
   <th>Discover Time</th>
   <th>Uniform Digest of Blob</th>
   <th>Byte Count</th>
   <th>Byte Bitmap</th>
   <th>Is UTF8 Well Formed?</th>
   <th>Prefix of 32 Bytes</th>
   <th>Suffix of 32 Bytes</th>
  </tr>
 </thead>
 <tbody>
END

#  Write the matching blobs <tr>

while (my $r = $qh->fetchrow_hashref()) {
	my $blob = encode_html_entities($r->{blob});
	my $discover_time = encode_html_entities($r->{discover_time});
	my $byte_count = $r->{match_page_count};
	my $byte_bitmap = encode_html_entities($r->{byte_bitmap});
	my $is_utf8wf = $r->{is_utf8wf};
	my $prefix = encode_html_entities($r->{prefix});
	my $suffix = encode_html_entities($r->{suffix});
	print <<END;
 <tr>
  <td>$discover_time</td>
  <td>$blob</td>
  <td>$byte_count</td>
  <td>$byte_bitmap</td>
  <td>$is_utf8wf</td>
  <td>$prefix</td>
  <td>$suffix</td>
 </tr>
END
}

print <<END;
 </tbody>
</table>
END

1;
