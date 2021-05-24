#
#  Synopsis:
#	Write html <dl> of invalid blobs which were candidates for json.
#  Usage:
#	/cgi-bin/jsonorg?out=dl.fail
#

require 'dbi-pg.pl';
require 'common-time.pl';
require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $offset = $QUERY_ARG{offset};

my $qh = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'jsonorg-select-fail-blob',
		argv =>	[
		],
		sql =>	q(
SELECT
	c.blob,
	extract(epoch FROM s.discover_time) AS discover_epoch,
	bc.byte_count,
	u8.is_utf8,
	f.file_type
  FROM
  	jsonorg.checker_255 c
	  JOIN setcore.service s ON (s.blob = c.blob)
	  JOIN setcore.byte_count bc ON (bc.blob = c.blob)
	  JOIN setcore.is_utf8wf u8 ON (u8.blob = c.blob)
	  JOIN fffile.file f ON (f.blob = c.blob)
  WHERE
  	NOT c.is_json
  ORDER BY
  	s.discover_time DESC
;
));

print <<END;
<dl$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $now = time();
while (my $r = $qh->fetchrow_hashref()) {
	my $blob = encode_html_entities($r->{blob});
	my $discover_elapsed = encode_html_entities(
				elapsed_seconds2terse_english(
					$now - $r->{discover_epoch}
				))
	;
	my $byte_count = $r->{byte_count};
	my $file_type = encode_html_entities($r->{file_type});
	print <<END;
 <dt>
  <a href="/schema/setcore/detail.shtml?blob=$blob">
   <code>$blob</code>
  </a>
 </dt>
 <dd>
   discovered $discover_elapsed ago,
   $byte_count bytes of $file_type
 </dd>
END
}

print <<END;
</dl>
END

1;
