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
<dl$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
 <thead>
END

my $qh = recent_select();

#  Write the matching blobs <tr>

while (my $r = $qh->fetchrow_hashref()) {
	my $blob = encode_html_entities($r->{blob});
	my $discover_elapsed = encode_html_entities($r->{discover_elapsed});
	my $byte_count = $r->{byte_count};
	my $bitmap = $r->{bitmap};
	$bitmap =~ s/0//g;
	my $byte_density = sprintf('%.1f %%', 100 * length($bitmap) / 256);
	my $is_utf8 = $r->{is_utf8};
	my $prefix = encode_html_entities($r->{prefix});
	my $suffix = encode_html_entities($r->{suffix});
	print <<END;
 <dt>$blob</dt>
 <dd>
   discovered: $discover_elapsed,
   size: $byte_count bytes,
   utf8: $is_utf8,
   byte density: $byte_density,
   prefix: $prefix,
   suffix: $suffix
 </dd>
END
}

print <<END;
</dl>
END

1;