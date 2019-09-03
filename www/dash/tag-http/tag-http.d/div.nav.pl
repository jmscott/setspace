#
#  Synopsis:
#	HTML Navigation bar for tag url search results
#
require 'dbi.pl';
require 'account.d/common.pl';

our %QUERY_ARG;

my (
	$rppg,
	$page,
	$host
) = (
	$QUERY_ARG{rppg},
	$QUERY_ARG{page},
	$QUERY_ARG{host},
);
my $pg_role = cookie2pg_role();

return 1 unless $pg_role;
$pg_role =~ s/\\/\\\\/g;
$pg_role =~ s/'/\\'/g;


#
#  Opening <div class="..." id="...">
#
print <<END;
<div$QUERY_ARG{class_att}$QUERY_ARG{id_att}>
END

#
#  Qualify on host
#
my ($sql_from_host, $sql_qual_host);
if ($host) {
	$host =~ s/\\/\\\\/g;
	$host =~ s/'/\\'/g;
	$sql_from_host =<<END;
inner join tag_url_host h on (h.blob = u.blob)
END
	$sql_qual_host =<<END;
and
h.value = E'$host' 
END
}

my $Q = dbi_select(
	db	=>	dbi_connect(),
	tag	=>	'tag-http-div.nav-count',
	#dump	=>	'>/tmp/tag-http-div.nav-count.sql',
	sql	=>	<<END
select
	count(distinct u.uri) as uri_count
  from
  	tag_url u
	$sql_from_host
  where
  	pg_role = '$pg_role'
	$sql_qual_host
;
END
);

my $row = $Q->fetchrow_hashref();
die "DBI->fetchrow_hashref() failed" unless $row;

my $count = $row->{uri_count};

#
#  No matches, so done.
#
if ($count == 0) {
	print <<END;
No Links found.
</div>
END
	return 1;
}

my $plural = $count == 1 ? '' : 's';

my $total_page = int($count / $rppg);
$total_page++ unless $count % $rppg == 0;
$plural = 's' unless $total_page == 1;

print <<END;
$count Link$plural 
END

print <<END;
Total, Page $page of $total_page
END

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
	put_nav_a($page - 1, 'Previous') if $page > 1;
	put_nav_a($page + 1, 'Next') if $page < $total_page;
}

print <<END;
</div>
END

1;
