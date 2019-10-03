#
#  Synopsis:
#	Write html <table> of all json blobs.
#  Usage:
#	/cgi-bin/jsonorg?out=table
#
use Time::HiRes qw(gettimeofday);

require 'httpd2.d/common.pl';
require 'jsonorg.d/common.pl';

our %QUERY_ARG;

print <<END;
<table$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
 <thead>
  <tr>
   <th>Discover Elapsed</th>
   <th>JSON Text < 256 Chars</th>
   <th>Character Count</th>
   <th>Discover Time</th>
   <th>Blob Uniform Digest</th>
  </tr>
 </thead>
 <tbody>
END

my $qh = select_recent();

#  Write the matching blobs <tr>

while (my $r = $qh->fetchrow_hashref()) {
	my $blob = encode_html_entities($r->{blob});
	my $discover_elapsed = encode_html_entities($r->{discover_elapsed});
	my $pretty_json_255 = encode_html_entities($r->{pretty_json_255});
	my $pretty_char_count = $r->{pretty_char_count};
	my $discover_time = encode_html_entities($r->{discover_time});
	print <<END;
 <tr>
  <td>$discover_elapsed</td>
  <td>$pretty_json_255</td>
  <td>$pretty_char_count</td>
  <td>$discover_time</td>
  <td>$blob</td>
 </tr>
END
}

print <<END;
 </tbody>
</table>
END

1;
