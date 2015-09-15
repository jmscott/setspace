#
#  Synopsis:
#	Logout of setspace account
#
require 'dbi.pl';

my $redirect = '/';

#
#  Extract the cookie
#
my $cookie = $ENV{HTTP_COOKIE};
unless ($cookie =~ /\bSETSPACE=([^;\s]+)/) {
	print <<END;
Status: 303
Location: $redirect
\r
END
}

$cookie = $1;

my $db = dbi_connect();

#
#  Delete the cookie.
#
dbi_do(
	#dump	=>	'>/tmp/delete-cookie.sql',
	tag	=>	'delete-cookie',
	db	=>	$db,
	sql	=>	<<END
delete from http_cookie where id = '$cookie';
END
);

#
#  Expire the cookie in the client and redirect.
#
print <<END;
Set-Cookie: SETSPACE=;  path=/;  expires=Thu, 01-Jan-1970 00:00:01 GMT;
Status: 303
Location: $redirect
\r
END

1;
