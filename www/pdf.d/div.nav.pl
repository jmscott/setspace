#
#  Synopsis:
#	HTML Navigation bar for pdf search results
#  Note:
#	Investigate set enable_mergejoin
#
require 'dbi.pl';
require 'account.d/common.pl';

my $pg_role = cookie2pg_role();
return 1 unless $pg_role;

our %QUERY_ARG;

use constant OBY2ENGLISH =>
{
	'tscd'		=>	['More Relavent', 'Less Relavent'], 
	'dtimd'		=>	['Newer', 'Older'],
	'dtima'		=>	['Older', 'Newer'],
	'pgcoa'		=>	['Smaller', 'Bigger'],
	'pgcod'		=>	['Bigger', 'Smaller'],
	'rand'		=>	['Previous', 'Next'],
};

my (
	$q,
	$rppg,
	$page,
	$oby,
) = (
	$QUERY_ARG{q},
	$QUERY_ARG{rppg},
	$QUERY_ARG{page},
	$QUERY_ARG{oby}
);

$q =~ s/^\s*$//;
$oby = 'dtimd' if $oby eq 'tscd' && !$q;

my ($prev, $next);
if ($oby) {
	($prev, $next) = (OBY2ENGLISH->{$oby}->[0], OBY2ENGLISH->{$oby}->[1]);
} elsif ($q) {
	($prev, $next) = (OBY2ENGLISH->{tscd}->[0], OBY2ENGLISH->{tscd}->[1]);
} else {
	#
	#  Assumes ordering by youngest -> oldest
	#
	($prev, $next) = ('Newer', 'Older');
}

#
#  Opening <div class="..." id="...">
#
print <<END;
<div$QUERY_ARG{class_att}$QUERY_ARG{id_att}>
END

my ($nq, $sql) = ($q);
if ($nq) {
	$nq =~ s/\\/\\\\/g;
	$nq =~ s/'/\\'/g;

	$sql =<<END;
select
	count(p.blob) as pdf_count
  from
  	plainto_tsquery('english', E'$nq') as q,
	/*
	 *  Only parsable pdf files.
	 */
  	pdfinfo p
	  left outer join title t on (p.blob = t.blob)
	  left outer join pdfinfo_title pit on (p.blob = pit.blob)
	  left outer join pdftotext_readable_tsv ptt on (p.blob = ptt.pdf_blob)
	  left outer join my_title mt on (
	  	p.blob = mt.blob
		and
		mt.pg_role = '$pg_role'
	  )
  where
	 t.value_tsv \@\@ q
	 or
  	 pit.value_tsv \@\@ q
	 or
	 ptt.value \@\@ q
	 or
	 mt.value_tsv \@\@ q
END
} else {
	$sql =<<END;
select
	reltuples as pdf_count
  from
  	pg_class
  where
  	relname = 'pdfinfo'
;
END
}

my $Q = dbi_select(
	db	=>	dbi_connect(),
	tag	=>	'pdf-div.nav-count',
	dump	=>	'>/tmp/pdf-div.nav-count.sql',
	#trace	=>	15,
	sql	=>	$sql
);


my $row = $Q->fetchrow_hashref();
die "DBI->fetchrow_hashref() failed" unless $row;

my $count = $row->{pdf_count};

#
#  No matches, so done.
#
if ($count == 0) {
	print <<END;
No documents found.
</div>
END
	return 1;
}

my $plural = $count == 1 ? '' : 's';

my $total_page = int($count / $rppg);
$total_page++ unless $count % $rppg == 0;
$plural = 's' unless $total_page == 1;

print <<END;
$count Document$plural 
END

if ($nq) {
	print <<END;
Matched, Page $page of $total_page
END
} else {
	print <<END;
Total, Page $page of $total_page
END
}

sub put_nav_a
{
	my ($pg, $text) = @_;
	my $ruri = $ENV{REQUEST_URI};
	my $rppg = $QUERY_ARG{rppg};

	#
	#  Replace 'page' query argument
	#
	#  Query arg ought to replaceed in function, not inline !!!
	# 
	if ($ruri =~ /([&?])page=\d+/) {
		if ($1 eq '?') {
			$ruri =~ s/[?]page=\d+/?page=$pg/;
		} else {
			$ruri =~ s/([&])page=\d+/&amp;page=$pg/;
		}
	} else {
		if ($ruri =~ /\&/) {
			$ruri .= "&amp;page=$pg";
		} else {
			if ($ruri =~ /[?]/) {
				$ruri .= "&amp;page=$pg";
			} else {
				$ruri .= "?page=$pg";
			}
		}
	}
	
	#
	#  Replace 'rppg' query argument
	# 
	if ($ruri =~ /([&?])rppg=\d+/) {
		if ($1 eq '?') {
			$ruri =~ s/[?]rppg=\d+/?rppg=$rppg/;
		} else {
			$ruri =~ s/([&])rppg=\d+/&amp;rppg=$rppg/;
		}
	} else {
		if ($ruri =~ /\&/) {
			$ruri .= "&amp;rppg=$rppg";
		} else {
			if ($ruri =~ /[?]/) {
				$ruri .= "&amp;rppg=$rppg";
			} else {
				$ruri .= "?rppg=$rppg";
			}
		}
	}
	print <<END;
<a href="$ruri">$text</a>
END
}

if ($total_page > 1) {
	print ': ';
	put_nav_a($page - 1, $prev) if $page > 1;
	put_nav_a($page + 1, $next) if $page < $total_page;
}

print <<END;
</div>
END

1;
