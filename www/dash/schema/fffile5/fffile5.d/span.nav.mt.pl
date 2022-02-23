#
#  Synopsis:
#	Write html <span> of for navigating search results
#  Note:
#

use utf8;

#  stop apache log message 'Wide character in print at ...' from arrow chars
binmode(STDOUT, ":utf8");

require 'dbi-pg.pl';
require 'pdfbox.d/common.pl';

our %QUERY_ARG;

my $mt = $QUERY_ARG{mt};
return 1 unless $mt;

my $off = $QUERY_ARG{off};
my $lim = $QUERY_ARG{lim};

my $r = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-span-stat',
		argv =>	[$mt],
		sql => q(
SELECT
	count(mt.blob) AS blob_count
  FROM
  	fffile5.file_mime_type mt
	  JOIN setcore.byte_count sz ON (sz.blob = mt.blob)
	  JOIN setcore.service srv ON (srv.blob = mt.blob)
  WHERE
  	mt.mime_type = $1
;)
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
No blobs with mime type $mt.</span>
END
	return 1;
}

if ($blob_count <= $lim) {
	my $plural = 's';
	$plural = '' if $blob_count == 1;

	print <<END;
$blob_count doc$plural matched
END
	return 1;
}

my $arrow_off;
$mt = encode_url_query_arg($mt);
if ($off >= $lim) {
	$arrow_off = $off - $lim;
	print <<END;
<a href=
"/schema/fffile5/index.shtml?mt=$mt&amp;off=$arrow_off&amp;lim=$lim">◀</a>
END
}

my $blob_lower = $off + 1;
my $blob_up = $blob_lower + $lim - 1;
$blob_up = $blob_count if $blob_up > $blob_count;

#  Note:
#	Rewrite with commas, english style.
#	Need a library here.
#
1 while $blob_lower =~ s/^(\d+)(\d{3})/$1,$2/;
1 while $blob_up =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
$blob_lower to $blob_up
END

$arrow_off = $off + $lim;
print <<END if $arrow_off < $blob_count;
<a href="/schema/fffile5/index.shtml?mt=$mt&amp;off=$arrow_off&amp;lim=$lim">▶</a>
END

#  add commas to numbers to render human readable
1 while $blob_count =~ s/^(\d+)(\d{3})/$1,$2/;

print <<END;
of $blob_count blobs matched</span>
END

1;
