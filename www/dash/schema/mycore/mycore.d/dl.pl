#
#  Synopsis:
#	Write html <dl> of all mycore attributes.
#  Usage:
#	/cgi-bin/schema/mycore?out=dl
#
use Time::HiRes qw(gettimeofday);

require 'dbi-pg.pl';
require 'httpd2.d/common.pl';
require 'mycore.d/common.pl';

our %QUERY_ARG;

my $q = $QUERY_ARG{q};
$q =~ s/^\s+|\s+$//g;

print <<END;
<dl$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $qh;
if ($q =~ /^[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}$/) {		# blob
	$qh = select_blob($q);
} elsif ($q) {
	print <<END;
  Query must be either a blob (udig) or empty.
</dl>
END
	return 1;
} else {
	$qh = select_recent();
}

#  Write the matching blobs <tr>

while (my $r = $qh->fetchrow_hashref()) {
	my $blob = encode_html_entities($r->{blob});
	my $discover_elapsed = encode_html_entities($r->{discover_elapsed});
	my $byte_count = $r->{byte_count};
	my $bitmap = $r->{bitmap};
	$bitmap =~ s/0//g;
	my $byte_coverage = sprintf('%.1f %%', 100 * length($bitmap) / 256);
	my $is_utf8 = 'UTF8';
	$is_utf8 = 'not UTF8' unless $r->{is_utf8};
	my $prefix = encode_html_entities($r->{prefix});
	my $suffix = encode_html_entities($r->{suffix});
	print <<END;
 <dt class="udig">$blob</dt>
 <dd>
  $discover_elapsed,
  $byte_count bytes,
  $is_utf8,
  $byte_coverage coverage,
  <span class="bytedump">$prefix</span> ...
  <span class="bytedump">$suffix</span>
  <a
    title="$blob Detail in SetCore"
    href="detail.shtml?blob=$blob"
  >Detail</a>
 </dd>
END
}

print <<END;
</dl>
END

1;
