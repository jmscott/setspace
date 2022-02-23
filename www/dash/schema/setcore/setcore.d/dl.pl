#
#  Synopsis:
#	Write html <dl> of all setcore attributes.
#  Usage:
#	/cgi-bin/schema/setcore?out=dl
#
use Time::HiRes qw(gettimeofday);

require 'dbi-pg.pl';
require 'common-time.pl';
require 'httpd2.d/common.pl';
require 'setcore.d/common.pl';

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

my $now = time();
while (my $r = $qh->fetchrow_hashref()) {
	my $blob = encode_html_entities($r->{blob});
	my $discover_elapsed = encode_html_entities(
					elapsed_seconds2terse_english(
						$now - $r->{discover_epoch}
				))
	;
	my $byte_count = 'unknown';
	$byte_count = $r->{byte_count} if defined $r->{byte_count};

	my $byte_coverage;

	if (defined($r->{bitmap})) {
		my $bitmap = $r->{bitmap};
		$bitmap =~ s/0//g;
		$byte_coverage = sprintf('%.1f %%', 100 * length($bitmap) /256);
	} else {
		$byte_coverage = 'unknown';
	}

	my $is_utf8;
	if (defined($r->{is_utf8})) {
		$is_utf8 = 'not ' unless $r->{is_utf8};
	} else {
		$is_utf8 = 'unknown';
	}

	my $prefix;
	if (defined($r->{prefix})) {
		$prefix = encode_html_entities($r->{prefix});
	} else {
		$prefix = 'unknown prefix';
	}

	my $suffix;
	if (defined($r->{suffix})) {
		$suffix = encode_html_entities($r->{suffix});
	} else {
		$suffix = 'unknown suffix';
	}

	print <<END;
 <dt class="udig">$blob</dt>
 <dd>
  $discover_elapsed ago,
  $byte_count bytes,
  ${is_utf8}UTF8,
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
