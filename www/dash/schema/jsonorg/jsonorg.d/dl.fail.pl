#
#  Synopsis:
#	Write html <dl> of invalid blobs which were candidates for json.
#  Usage:
#	/cgi-bin/jsonorg?out=dl.fail
#
use Time::HiRes qw(gettimeofday);

require 'dbi-pg.pl';
require 'httpd2.d/common.pl';

my $qh = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'jsonorg-select-fail-blob',
		sql =>	<<END
SELECT
	c.blob,
	extract(epoch FROM s.discover_time) AS discover_epoch,
	u8.is_utf8,
	f.file_type
  FROM
  	jsonorg.checker_255 c
	  JOIN setcore.service s ON (s.blob = c.blob)
	  JOIN setcore.is_utf8wf u8 ON (u8.blob = c.blob)
	  JOIN fffile.file f ON (f.blob = c.blob)
  WHERE
  	NOT c.is_json
  ORDER BY
  	s.discover_time DESC
  LIMIT
  	10
;
END
);

print <<END;
<dl$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

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
