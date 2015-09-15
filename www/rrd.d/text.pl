#
#  Synopsis:
#	Convert Round Robin Database Time Intervals into English HTML Text
#
#  Blame:
#	john.scott@americanmessaging.net, jmscott@setspace.com
#

require 'rrd.d/common.pl';

our %QUERY_ARG;

print <<END;
Content-Type: text/html

END

if (my $start = $QUERY_ARG{start}) {
	print text2html(time_interval2english($start));
}

1;
