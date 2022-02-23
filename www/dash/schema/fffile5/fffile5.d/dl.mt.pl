#
#  Synopsis:
#	Write html <dl> of blobs of a certain mime type.
#

require 'httpd2.d/common.pl';
require 'dbi-pg.pl';

our %QUERY_ARG;

my $mt = $QUERY_ARG{mt};

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
				$mt
			],
	sql =>		q(
SELECT
	mt.blob,
	sz.byte_count,
	srv.discover_time
  FROM
  	fffile5.file_mime_type mt
	  JOIN setcore.byte_count sz ON (sz.blob = mt.blob)
	  JOIN setcore.service srv ON (srv.blob = mt.blob)
  WHERE
  	mt.mime_type = $1
;
));

while (my $r = $q->fetchrow_hashref()) {
	my $blob = $r->{blob};
	my $byte_count = $r->{byte_count};
	my $discover_time = $r->{discover_time};

print <<END;
 <dt><a href="/cgi-bin/schema/fffile5?out=mime.mt&blob=$blob">$blob</a></dt>
 <dd>
  $byte_count bytes, discovered $discover_time
 </dd>
END
}

print '</dl>';

1;
