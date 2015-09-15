#
#  Synopsis:
#	HTML Navigation bar for blob search results
#  Note:
#	Investigate set enable_mergejoin
#
require 'dbi.pl';
require 'account.d/common.pl';
require 'pdf.d/query.pl';

our %QUERY_ARG;

my (
	$udig,
	$rppg,
	$page,
	$mime,
	$oby
) = (
	$QUERY_ARG{udig},
	$QUERY_ARG{rppg},
	$QUERY_ARG{page},
	$QUERY_ARG{mime},
	$QUERY_ARG{oby},
);
my ($db, $pg_role, $Q) = (dbi_connect(), cookie2pg_role());

#
#  Opening <div class="..." id="...">
#
print <<END;
<div$QUERY_ARG{class_att}$QUERY_ARG{id_att}>
END

my ($count, $sql) = (0);
if ($mime) {			#  qualify on mime type
	my $m = $mime;

	$m =~ s/'/\\'/g;
	$m =~ s/\\/\\\\/g;

	my $sql_where = "f.readable = E'$m'";
	if (my $ud = $udig) {				#  particular blob
		$ud =~ s/'/\\'/g;
		$ud =~ s/\\/\\\\/g;
		$sql_where .= " and f.blob = E'$ud'"; 
	}
	$sql =<<END;
  select
	count(f.blob)
  from
  	file_mime f
  where
  	$sql_where
END
} elsif ($udig) {
	my $ud = $udig;

	$ud =~ s/'/\\'/g;
	$ud =~ s/\\/\\\\/g;
	my ($sql_where, $sql_from);
	if (my $m = $mime) {
		$m =~ s/'/\\'/g;
		$m =~ s/\\/\\\\/g;

		$sql_from = ",file f";
		$sql_where =<<END
	f.blob = b.id
	and
	f.readable = E'$m';
END
	}
	$sql =<<END
  select
  	count(b.id)
    from
    	blob b
	$sql_from
    where
    	b.id = E'$ud'
	$sql_where
END
} else {		#  no qualification, grab estimate from system tables
	$sql =<<END;
select
	reltuples
  from
  	pg_class
  where
  	relname = 'blob'
;
END
}

my $q = dbi_select(
	tag	=>	'blob-div.nav',
	#dump	=>	'>/tmp/blob-div-nav.sql',
	sql	=>	$sql
);

$count  = $q->fetchrow_array();
die "db_select(blob-div.nav) failed" unless defined $count;

#
#  No matches, so done.
#
if ($count == 0) {
	print <<END;
No blobs found.
</div>
END
	return 1;
}

my $plural = $count == 1 ? '' : 's';

my $total_page = int($count / $rppg);
$total_page++ unless $count % $rppg == 0;
$plural = 's' unless $total_page == 1;

print <<END;
$count Blob$plural 
END

if ($mime) {
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

	#
	#   Add replace page query argument
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
	#  Add/Replace mime query argument
	#
	my $v = encode_url_query_arg($mime);
	if ($ruri =~ /([&?])mime=([^&?]*)/) {
		if ($1 eq '?') {
			$ruri =~ s/[?]mime=[^&?]*/?mime=$v/;
		} else {
			$ruri =~ s/([&])mime=[^&?]*/&amp;mime=$v/;
		}
	} else {
		if ($ruri =~ /\&/) {
			$ruri .= "&amp;mime=$v";
		} else {
			if ($ruri =~ /[?]/) {
				$ruri .= "&amp;mime=$v";
			} else {
				$ruri .= "?mime=$v";
			}
		}
	}

	#
	#  Add/Replace oby query argument
	#
	$v = encode_url_query_arg($oby);
	if ($ruri =~ /([&?])oby=([^&?]*)/) {
		if ($1 eq '?') {
			$ruri =~ s/[?]oby=[^&?]*/?oby=$v/;
		} else {
			$ruri =~ s/([&])oby=[^&?]*/&amp;oby=$v/;
		}
	} else {
		if ($ruri =~ /\&/) {
			$ruri .= "&amp;oby=$v";
		} else {
			if ($ruri =~ /[?]/) {
				$ruri .= "&amp;oby=$v";
			} else {
				$ruri .= "?oby=$v";
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
