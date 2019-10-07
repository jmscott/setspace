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
require 'setcore.d/common.pl';

our %QUERY_ARG;

my $q = $QUERY_ARG{q};
$q =~ s/^\s+|\s+$//g;
my $offset = $QUERY_ARG{offset};
my $limit = 10;

my $WHERE;
if ($q =~ /^[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}$/) {		# blob
	$WHERE =<<END;
WHERE
  	s.blob = '$q'::udig
END
}

my $r = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'setcore-select-span-stat',
		sql => <<END
SELECT
	count(*) AS blob_count
  FROM
  	setcore.service s
  $WHERE
END
)->fetchrow_hashref();

my $blob_count = $r->{blob_count};

print <<END;
<span
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>
END

if ($blob_count == 0) {
	print <<END;
No Blobs in Service</span>
END
	return 1;
}

if ($blob_count <= $limit) {
	my $plural = 's';
	$plural = '' if $blob_count == 1;

	print <<END;
$blob_count blob$plural in service.
END
	return 1;
}

my $arrow_off;
if ($offset >= $limit) {
	$arrow_off = $offset - $limit;
	print <<END;
<a href="/schema/setcore/index.shtml?offset=$arrow_off">◀</a>
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
<a href="/schema/setcore/index.shtml?offset=$arrow_off">▶</a>
END

#  add commas to numbers to render human readable
1 while $blob_count =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
of $blob_count blobs in service
</span>
END

1;
