#
#  Synopsis:
#	Create a new setspace account
#
require 'dbi.pl';

our %POST_VAR; 

my (
	$role,
	$passwd,
	$passwdv,
) = (
	$POST_VAR{role},
	$POST_VAR{passwd},
	$POST_VAR{passwdv},
);

$ENV{PGUSER} = 'postgres';

unless ($passwd eq $passwdv) {
	my $uri = zap_uri_query_arg($ENV{HTTP_REFERER}, 'err');
	$uri = add_uri_query_arg($uri, 'err', 'Password does not match verify');

	print <<END;
Status: 303
Location: $uri
\r
END
	return 1;
}

$passwd =~ s/'/\\'/g;		# escape quote character

my $db = dbi_connect();

#
#   Ensure user does not already exist.  We must be super user.
#
my $q = dbi_select(
	tag =>	'select-role',
	db =>	$db,
	sql =>	<<END
select
	rolname
  from
  	pg_roles
  where
  	rolname = '$role'
END
);

if ($q->fetchrow_hashref()) {
	my $uri = zap_uri_query_arg($ENV{HTTP_REFERER}, 'err');
	$uri = add_uri_query_arg($uri, 'err', "Account $role already exists");
	print <<END;
Status: 303
Location: $uri
\r
END
	return 1;
}

#
#  Create the role.
#
dbi_do(
	#dump	=>	'>/tmp/create-role.sql',
	tag	=>	'create-role',
	db	=>	$db,
	sql	=>	<<END
create role "$role" with
	login
	unencrypted password E'$passwd'
;
END
);

my $set_cookie;
if ($ENV{HTTP_COOKIE} =~ /\bSETSPACE=([^;\s])/) {
	my $cookie = $1;
	#
	#  Insert the cookie.
	#
	dbi_do(
		#dump	=>	'>/tmp/delete-http-cookie.sql',
		tag	=>	'delete-http-cookie',
		db	=>	dbi_connect(),
		sql	=>	<<END
				delete from http_cookie
				  where
					id = '$cookie'
				;
END
	);
	print <<END;
Set-Cookie: SETSPACE=$cookie;  path=/;  expires=Thu, 01-Jan-1970 00:00:01 GMT;
END
}

#
#  Redirect to /login.shtml.
#
print <<END;
Status: 303
Location: /login.shtml
\r
END

1;
