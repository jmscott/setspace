#
#  Synopsis:
#	Write html <table> of all setcore attributes.
#  Usage:
#	/cgi-bin/setcore?out=table
#
use Time::HiRes qw(gettimeofday);

require 'dbi-pg.pl';
require 'common-time.pl';
require 'httpd2.d/common.pl';
require 'jsonorg.d/common.pl';

our %QUERY_ARG;

print <<END;
<dl$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $qh;
if ($QUERY_ARG{q} =~ m/^\s*[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}\s*$/) {
	$qh = select_json_blob();
} elsif ($QUERY_ARG{q} =~ /[[:graph:]]/) {
	$qh = select_json_query();
} else {
	$qh = select_recent();
}

my $now = time();
while (my $r = $qh->fetchrow_hashref()) {
	my $li_json_class = 'json';
	my $blob = encode_html_entities($r->{blob});
	my $pretty_json_255 = encode_html_entities($r->{pretty_json_255});
	if ($r->{pretty_char_count} > 255) {
		$li_json_class .= ' truncated';
		$pretty_json_255 .= ' <span class="truncate">...</span>';
	}
	my $discover_elapsed = encode_html_entities(
				elapsed_seconds2terse_english(
					$now - $r->{discover_epoch}
				))
	;	
	print <<END;
 <dt><code>$pretty_json_255</code></dt>
 <dd>
   discovered $discover_elapsed ago,
   <a
     href="/schema/jsonorg/detail.shtml?blob=$blob"
     title="$blob"
   >Detail</a>
 </dd>
END
}

print <<END;
</dl>
END

1;
