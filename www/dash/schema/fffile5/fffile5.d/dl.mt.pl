#
#  Synopsis:
#	Write html <dl> of blobs of a certain mime type.
#

require 'httpd2.d/common.pl';
require 'dbi-pg.pl';
require 'common-time.pl';

our %QUERY_ARG;

use Data::Dumper;
print STDERR 'WTF: ', Dumper(%QUERY_ARG), "\n";

my $mt = $QUERY_ARG{mt};
my $lim = $QUERY_ARG{lim};
my $off = $QUERY_ARG{off};

print <<END;
<dl
  name="fffile5-mt-dl"
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>
END

unless ($mt) {
	print <<END;
</dl>
END
	return 1;
}

my $q = dbi_pg_select(
	db =>		dbi_pg_connect(),
	tag =>		'fffile5-dl-mt',
	argv =>		[
				$mt,
				$off,
				$lim,
			],
	sql =>		q(
SELECT
	mt.blob,
	sz.byte_count,
	EXTRACT(epoch FROM srv.discover_time) AS discover_epoch
  FROM
  	fffile5.file_mime_type mt
	  JOIN setcore.byte_count sz ON (sz.blob = mt.blob)
	  JOIN setcore.service srv ON (srv.blob = mt.blob)
  WHERE
  	mt.mime_type = $1
  ORDER BY
  	srv.discover_time DESC
  OFFSET
  	$2
  LIMIT
  	$3
;
));

my $now = time();
while (my $r = $q->fetchrow_hashref()) {
	my $blob = $r->{blob};
	my $byte_count = $r->{byte_count};
	my $discover_english_text = elapsed_seconds2terse_english(
					$now - $r->{discover_epoch}
				) . ' ago' 
	;
print <<END;
 <dt><a href="/cgi-bin/schema/fffile5?out=mime.mt&blob=$blob">$blob</a></dt>
 <dd>
  $byte_count bytes, $discover_english_text
 </dd>
END
}

print '</dl>';

1;
