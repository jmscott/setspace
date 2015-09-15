#
#  Synopsis:
#	Create a new setspace account
#
require 'dbi.pl';
require 'blob.pl';

our %POST_VAR; 

my (
	$role,
	$passwd,
) = (
	$POST_VAR{role},
	$POST_VAR{passwd},
);

my (
	$algorithm,
	$cookie_age_interval,
	$cookie_age_sec
) = (
	'sha',
	'1 Year',
	31536000
);

$passwd =~ s/'/\\'/g;		# escape quote character

my $db = dbi_connect();

#
#   Ensure user does not already exist.  We must be super user.
#
my $q = dbi_select(
	#dump =>	'>/tmp/select-pg-shadow.sql',
	tag =>	'select-pg-shadow',
	db =>	$db,
	sql =>	<<END
select
	passwd
  from
  	pg_shadow
  where
  	usename = '$role'
	and
	passwd = '$passwd'
END
);

#
#  Invalid login
#
unless ($q->fetchrow_hashref()) {
	my $uri = zap_uri_query_arg($ENV{HTTP_REFERER}, 'err');
	$uri = add_uri_query_arg($uri, 'err', "Login Failed for $role");
	print <<END;
Status: 303
Location: $uri
\r
END
	return 1;
}

my $cookie = cgi2blob();

#
#  Insert the cookie.
#
dbi_do(
	#dump	=>	'>/tmp/insert-http-cookie.sql',
	tag	=>	'insert-http-cookie',
	db	=>	$db,
	sql	=>	<<END
begin;
insert into
  http_cookie
  	(id)
  values
  	('$cookie')
;
insert into
  http_cookie_age
  	(cookie_id, age)
  values
  	('$cookie', '$cookie_age_interval')
;
insert into
  http_cookie_role
  	(cookie_id, pg_role)
  values
  	('$cookie', '$role')
;
commit;
END
);

#
#  Calculate cookie expiration
#
my ($day, $month, $num, $time, $year) =
			split(/\s+/, gmtime(time() + $cookie_age_sec));
$num = "0$num" if length($num) == 1;
my $expires = "$day $num-$month-$year $time GMT";

#
#  Redirect to /
#
print <<END;
Set-Cookie: SETSPACE=$cookie;  path=/;  expires=$expires
Status: 303
Location: /
\r
END

1;
