#
#  Synopsis:
#	Write html <dl> of pdf documents that match keyword search.
#  Usage:
#	/cgi-bin/pdfbox?out=dl&q=neural+cryptography
#
use utf8;

#  stop apache log message 'Wide character in print at ...' from arrow chars
binmode(STDOUT, ":utf8");

use Time::HiRes qw(gettimeofday);

require 'dbi-pg.pl';
require 'httpd2.d/common.pl';
require 'pdfbox.d/common.pl';

our %QUERY_ARG;

print <<END;
<dl $QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $qh;
if ($QUERY_ARG{q} =~ m/[[:graph:]]/) {
	my $qtype = $QUERY_ARG{qtype};

	if ($qtype eq 'phrase') {
		$qh = phrase_select();
	} elsif ($qtype eq 'fts') {
		$qh = fts_select();
	} else {
		$qh = keyword_select();
	}
} else {
	$qh = recent_select();
}

#  write the <dt> as <a>title<a> link to the pdf blob
#  write the <dt> as the details of the pdf blob

while (my $r = $qh->fetchrow_hashref()) {
	#  every pdf has these four attributes
	my $blob = encode_html_entities($r->{blob});
	my $title = encode_html_entities($r->{title});
	my $number_of_pages = $r->{number_of_pages};
	my $discover_elapsed = $r->{discover_elapsed};

	#  strip off tailing hours:min:sec if more than day elapsed
	$discover_elapsed =~ s/ \d\d:\d\d:\d\d//
		if $discover_elapsed =~ m/(?:(day|mon|year)(?:s)?)/;
	$discover_elapsed = encode_html_entities($discover_elapsed);

	#  build the <dt> using the title
	my $dt_class;
	unless ($title =~ m/[[:graph:]]/) {
		$title = 'No Title';
		$dt_class = ' class="no-title"';
	}
	my $plural_nop = 's';
	$plural_nop = '' if $number_of_pages == 1;

	my $snippet = $r->{snippet};
	my $span_snippet = <<END if $snippet =~ /[[:graph:]]/;
   <span class="snippet">$snippet</span>
END

	#  build the row
	print <<END;
 <dt$dt_class>$title</dt>
 <dd>
   $span_snippet
   <span class="detail">
     $number_of_pages page$plural_nop,
     $discover_elapsed
   </span>
 </dd>
END
}

print <<END;
</dl>
END
