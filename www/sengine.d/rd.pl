#
#  Synopsis
#	Log and redirect a search to the chosen engine.
#

require 'sengine.d/common.pl';
require 'blob.pl';

our (%POST_VAR, %SEARCH_ENGINE);

my $eng = $POST_VAR{eng};
my $cookie_age_sec = 31536000;		#  1 year

unless ($eng) {
	my $e = 'missing post variable: eng';

	print <<END;
Status: 500
Content-Type: text/plain

ERROR: $e
END
	cgi2blob(
		extra	=>	'<error>' . text2xml($e) . '</error>'
	);
	die $e;
}

#
#  For each group of engines at a particular site ...
#
my $callback;
for my $ogk (sort keys %SEARCH_ENGINE) {
	my $og = $SEARCH_ENGINE{$ogk};

	#
	#  Search tags for this site group of engines.
	#
	for my $ok (sort keys %{$og}) {
		next unless $ok eq $eng;

		$callback = $og->{$ok}->[1];
		last;
	}
	last if $callback;
}

unless ($callback) {
	my $e = "unknown search engine tag: $eng";
	print <<END;
Status: 500
Content-Type: text/plain

ERROR: $e
END
	cgi2blob(
		extra	=>	'<error>' . text2xml($e) . '</error>'
	);
	die $e;
}

my $location = &$callback;

#
#  Save the previous search engine in a cookie.
#
my $expires;
{
	my ($day, $month, $num, $time, $year) =
				split(/\s+/, gmtime(time() + $cookie_age_sec));
	$num = "0$num" if length($num) == 1;
	$expires = "$day $num-$month-$year $time GMT";
}

print <<END;
Status: 303
Set-Cookie: SETSPACE_SENGINE=$eng;  path=/;  expires=$expires
Location: $location

END

$location = text2xml($location);
cgi2blob(
	extra	=>	<<END
<location>$location</location>
END
);

exit 0;
