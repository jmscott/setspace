#
#  Synopsis:
#	Write html <span> of for navigating search results
#  Note:
#	Add query argument "lim"
#	Consider pretty printing using use POSIX qw(locale_h)
#	instead of english style 999,999.
#
#	One day this query may be a materialized view.
#

use utf8;

#  stop apache log message 'Wide character in print at ...' from arrow chars
binmode(STDOUT, ":utf8");

require 'dbi-pg.pl';
require 'jsonorg.d/common.pl';

our %QUERY_ARG;

my $q = $QUERY_ARG{q};
$q =~ s/^\s*|\s*$//g;		#  strip white space

my $offset = $QUERY_ARG{offset};
my $limit = 10;

my $r;

#  fetch json docs by top level key, particular udig or all json.
if ($q =~ m/^[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}$/) {	#  find udig
	$r = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'jsonorg-select-blob-span-stat',
		argv =>	[
				$q
			],
		sql => q(
SELECT
	count(blob) AS blob_count
  FROM
  	jsonorg.jsonb_255
  WHERE
  	blob = $1
));
} elsif ($q =~ m/[[:graph:]]/) {
	$r = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'jsonorg-select-query-span-stat',
		argv =>	[
				$q
			],
		sql => q(
SELECT
	count(*) AS blob_count
  FROM
	jsonorg.jsonb_255 jb
  WHERE
  	jb.doc \? $1
));
	$q = encode_url_query_arg($q);
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
));
}

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

if ($blob_count <= $limit) {
	my $plural = 's';
	$plural = '' if $blob_count == 1;

	print <<END;
$blob_count json blob$plural matched
END
	return 1;
}

my $arrow_off;
if ($offset >= $limit) {
	$arrow_off = $offset - $limit;
	print <<END;
<a href="/schema/jsonorg/index.shtml?offset=$arrow_off&q=$q">◀</a>
END
}

my $lower = $offset + 1;
1 while $lower =~ s/^(\d+)(\d{3})/$1,$2/;

my $upper = $lower + $limit - 1;
$upper = $blob_count if $upper > $blob_count;
1 while $upper =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
$lower to $upper
END

$arrow_off = $offset + $limit;
print <<END if $arrow_off < $blob_count;
<a href="/schema/jsonorg/index.shtml?offset=$arrow_off&q=$q">▶</a>
END

#  add commas to numbers to render human readable
1 while $blob_count =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
of $blob_count json blobs matched
</span>
END

1;
