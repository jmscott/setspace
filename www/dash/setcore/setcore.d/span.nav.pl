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

my $offset = $QUERY_ARG{offset};
my $limit = 10;

my $r = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-span-stat',
		sql => q(
SELECT
	count(*) AS blob_count
  FROM
  	setcore.service s
	  JOIN setcore.byte_count bc ON (bc.blob = s.blob)
	  JOIN setcore.is_utf8wf u8 ON (u8.blob = s.blob)
	  JOIN setcore.byte_bitmap bit ON (bit.blob = s.blob)
	  JOIN setcore.byte_prefix_32 p32 ON (p32.blob = s.blob)
	  JOIN setcore.byte_suffix_32 s32 ON (s32.blob = s.blob)
))->fetchrow_hashref();

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
<a href="/setcore/index.shtml?offset=$arrow_off">◀</a>
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
<a href="/setcore/index.shtml?offset=$arrow_off">▶</a>
END

#  add commas to numbers to render human readable
1 while $blob_count =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
of $blob_count blobs in service
</span>
END

1;
