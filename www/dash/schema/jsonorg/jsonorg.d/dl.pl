#
#  Synopsis:
#	Write html <table> of all setcore attributes.
#  Usage:
#	/cgi-bin/setcore?out=table
#
use Time::HiRes qw(gettimeofday);

require 'dbi-pg.pl';
require 'httpd2.d/common.pl';
require 'jsonorg.d/common.pl';

our %QUERY_ARG;

print <<END;
<dl$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $qh = dbi_pg_select(
		db =>   dbi_pg_connect(),
		tag =>  'jsonorg-recent_select',
		argv =>	[
				$QUERY_ARG{lim},
				$QUERY_ARG{offset},
			],
		sql =>	q(
SELECT
	c.blob
  FROM
  	jsonorg.checker_255 c
	  JOIN setcore.service s ON (s.blob = c.blob)
	  JOIN jsonorg.jsonb_255 jb ON (jb.blob = c.blob)
  ORDER BY
  	s.discover_time desc
  LIMIT
  	$1
  OFFSET
  	$2
;
		)

#  Write the matching blobs <tr>

while (my $r = $qh->fetchrow_hashref()) {
	my $blob = encode_html_entities($r->{blob});
	print <<END;
 <dt>$blob</dt>
 <dd>
   discovered: $discover_elapsed,
   size: $byte_count bytes,
   utf8: $is_utf8,
   byte density: $byte_density,
   prefix: $prefix,
   suffix: $suffix
 </dd>
END
}

print <<END;
</dl>
END

1;
