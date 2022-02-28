#
#  Synopsis:
#	Write html <span> of for navigating json search results
#  Note:
#	Consider pretty printing using use POSIX qw(locale_h)
#	instead of english style 999,999.
#

use utf8;

#  stop apache log message 'Wide character in print at ...' from arrow chars
binmode(STDOUT, ":utf8");

require 'dbi-pg.pl';
require 'jsonorg.d/common.pl';

our %QUERY_ARG;

my $topk = $QUERY_ARG{topk};
my $off = $QUERY_ARG{off};
my $lim = $QUERY_ARG{lim};

my $r;

#  fetch json docs by top level key, particular udig or all json.
if (defined($topk)) {
	$r = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'jsonorg-select-jsonorg-span',
		argv =>	[
				$topk
			],
		sql => q(
SELECT
	count(blob) AS blob_count
  FROM
  	jsonorg.jsonb_255
  WHERE
  	doc \\? $1
));
} else {
	$r = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'jsonorg-select-query-span-stat',
		argv =>	[],
		sql => q(
SELECT
	count(*) AS blob_count
  FROM
	jsonorg.jsonb_255 jb
))};

my $blob_count = $r->fetchrow_hashref()->{blob_count};

print <<END;
<span
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>
END

if ($blob_count == 0) {
	print <<END;
No JSON blobs.</span>
END
	return 1;
}

if ($blob_count <= $lim) {
	my $plural = 's';
	$plural = '' if $blob_count == 1;

	print <<END;
$blob_count json blob$plural matched
END
	return 1;
}

my $arrow_off;
if ($off >= $lim) {
	$arrow_off = $off - $lim;
	print <<END;
<a href="/schema/jsonorg/index.shtml?off=$arrow_off&topk=$topk">◀</a>
END
}

my $lower = $off + 1;
1 while $lower =~ s/^(\d+)(\d{3})/$1,$2/;

my $upper = $lower + $lim - 1;
$upper = $blob_count if $upper > $blob_count;
1 while $upper =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
$lower to $upper
END

$arrow_off = $off + $lim;
print <<END if $arrow_off < $blob_count;
<a href="/schema/jsonorg/index.shtml?off=$arrow_off&topk=$topk">▶</a>
END

#  add commas to numbers to render human readable
1 while $blob_count =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
of $blob_count json blobs matched
</span>
END

1;
