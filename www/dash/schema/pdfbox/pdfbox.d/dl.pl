#
#  Synopsis:
#	Write html <dl> of pdf documents that match keyword search.
#  Usage:
#	/cgi-bin/pdfbox?out=dl&q=neural+cryptography
#  Note:
#	--  investigate why elspased-query-time is not high resolution.
#
#	--  The following phrase search with a colon fails
#
#		"Picasso: Design and Implementation"
#
#	but works without the colon:
#
#		"Picasso Design and Implementation"
#
#	matching this pdf
#
#		bc160:c921ea224158699ffbf7e5353ea811fb1f82255b
#
use utf8;
use Time::HiRes qw(gettimeofday);

require 'utf82blob.pl';
require 'dbi-pg.pl';
require 'common-json.pl';
require 'common-time.pl';
require 'httpd2.d/common.pl';
require 'pdfbox.d/common.pl';

#  unbuffer output
select(STDOUT);  $| = 1;

#  stop apache log message 'Wide character in print at ...' from arrow chars
binmode(STDOUT, ":utf8");

our %QUERY_ARG;

print <<END;
<dl$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $qh;

#  replace with ENV var BLOBIO_KNOWN_ALGORITHMS

my $q = $QUERY_ARG{q};

#  either find a particular pdf, do a full text search or get most
#  recent pdf files.

my $qtype;
my $query_start_time = time();
if ($q =~ m/^\s*[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}\s*$/) {	#  find blob
	$qh = select_pdf_blob();
	$qtype = 'blob';
} elsif ($q =~ /^\s*=/) {
	$qh = fts_select();
	$qtype = 'fts';
} elsif ($q =~ m/[[:graph:]]/) {				#  text query
	$qh = websearch_select();
	$qtype = 'web';
} else {
	$qh = recent_select();
	$qtype = 'recent';
}
my $elapsed_query_seconds = time() - $query_start_time;

#  write the <dt> as <a>title<a> link to the pdf blob
#  write the <dt> as the details of the pdf blob

my $now = time();
while (my $r = $qh->fetchrow_hashref()) {
	#  every pdf has these four attributes
	my $blob = $r->{blob};
	my $title = encode_html_entities($r->{title});
	my $number_of_pages = $r->{number_of_pages};
	my $match_page_count = $r->{match_page_count};

	my $match_page_count_text = <<END if $match_page_count > 0;
      $match_page_count matched of
END

	my $discover_english_text = elapsed_seconds2terse_english(
					$now - $r->{discover_epoch}
				) . ' ago' 
	;

	#  build the <dt> using the title
	my $dt_class;
	unless ($title =~ m/[[:graph:]]/) {
		$title = 'No Title';
		$dt_class = ' class="no-title"';
	}
	my $plural_nop = 's';
	$plural_nop = '' if $number_of_pages == 1;

	my $mytitle_is_null = $r->{mytitle_is_null};

	my $snippet = $r->{snippet};
	$snippet =~ s/<b>/MAGIC_RANDOM_STRING196010915/g;
	$snippet =~ s@</b>@MAGIC_RANDOM_STRING20380101@g;
	$snippet = encode_html_entities($snippet);
	$snippet =~ s@MAGIC_RANDOM_STRING20380101@</b>@g;
	$snippet =~ s/MAGIC_RANDOM_STRING196010915/<b>/g;

	my $span_snippet = <<END if $snippet =~ /[[:graph:]]/;
   <span class="snippet">$snippet</span>
END

	my $a_title =<<END if $mytitle_is_null eq '1';
<a href="/schema/pdfbox/title.shtml?blob=$blob">, Title</a>
END
	#  build the row
	print <<END;
 <dt$dt_class>
  <a href="/cgi-bin/pdfbox?out=mime.pdf&amp;udig=$blob">$title</a>
 </dt>
 <dd>
   $span_snippet
   <span class="detail">
     $match_page_count_text $number_of_pages page$plural_nop total,
     $discover_english_text,
     <a
       class="detail"
       href="/schema/pdfbox/detail.shtml?blob=$blob"
       title="$blob"
     >Detail</a>$a_title
   </span>
 </dd>
END
}

print <<END;
</dl>
END

return 1 unless $q;		#  no search so nothing to record

#  save the user text search as a json blob in mydash.schema.setspace.com

$q = utf82json_string($QUERY_ARG{q});
$qtype = utf82json_string($qtype);
my $query_epoch = time();

my $env = env2json(2);

#  Note: add the array of matching blob?

print STDERR 'pdfbox-full-text-search: json: ', utf82blob(<<END), "\n";
{
	"mydash.schema.setspace.com": {
		"pdfbox-full-text-search": {
			"q": $q,
			"qtype": $qtype
		},
		"elapsed-query-seconds": $elapsed_query_seconds,
		"query_epoch": $query_epoch
	},
	"cgi-bin-environment": $env
}
END
;

1;
