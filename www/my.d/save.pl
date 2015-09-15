#
#  Synopsis:
#	Create a new setspace account
#
require 'dbi.pl';
require 'account.d/common.pl';

our %POST_VAR; 

#
#  Verfied we have logged in.
#  Eventually will move to xml/cgi level.
#
my $pg_role = cookie2pg_role();
unless ($pg_role) {
	print <<END;
Status: 401
Location: /login.shtml

END
}

return 1 unless $pg_role;

my (
	$udig,
	$blob_title,
) = (
	$POST_VAR{udig},
	$POST_VAR{'blob-title'},
);

$blob_title =~ s/'/\\'/g;

#
#   Ensure user does not already exist.  We must be super user.
#
my $q = dbi_do(
	db	=>	dbi_connect(),
	#dump =>	'>/tmp/my-save.sql',
	tag =>		'my-save',
	sql =>	<<END
insert into my_title(pg_role, blob, value)
  select
  	'$pg_role',
	'$udig',
	E'$blob_title'
  where
  	not exists (
	  select
	  	blob
	    from
	    	my_title
	    where
	    	pg_role = '$pg_role'
		and
		blob = '$udig'
	)
;
update my_title
  set
  	value = E'$blob_title'
  where
  	pg_role = '$pg_role'
	and
	blob = '$udig'
;
END
);

print <<END;
Status: 303
Location: /blob-detail.shtml?udig=$udig
\r
END

1;
