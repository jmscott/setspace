#
#  Synopsis:
#	Write html <dl> of pdf documents that match keyword search.
#  Usage:
#	/cgi-bin/pdfbox?out=dl&q=neural+cryptography
#
use Time::HiRes qw(gettimeofday);

require 'dbi-pg.pl';
require 'httpd2.d/common.pl';
require 'pdfbox.d/common.pl';

our %QUERY_ARG;

print <<END;
<dl $QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $qh = recent_select();
while (my $r = $qh->fetchrow_hashref()) {
	my $blob = encode_html_entities($r->{blob});
	my $title = encode_html_entities($r->{title});
	my $dt_class;
	unless ($title =~ m/[[:graph:]]/) {
		$title = 'No Title';
		$dt_class = ' class="no-title"';
	}
	my $number_of_pages = $r->{number_of_pages};
	my $discover_time = $r->{discover_time};
	my $plural_nop = 's';
	$plural_nop = '' if $number_of_pages == 1;
	print <<END;
 <dt$dt_class>$title</dt>
 <dd>$number_of_pages page$plural_nop, discovered $discover_time</dd>
END
}

print <<END;
</dl>
END
