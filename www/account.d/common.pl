#
#  Synopsis:
#	Support functions for account authentification.
#  Returns:
#  	($cookie, $pg_role)
#  Usage:
#	#
#	#  Scalar Context:
#	#	Pop the postgresql role off top of perl return "stack";
#	#	i.e., the LAST element.
#	#
#  	my $pg_role = cookie2pg_role();
#
#	#
#	#  List Context:
#	#	Return the cookie and pg role cast as list in reverse
#	#	stack order. Try doing (or wanting to do) THAT in a single line
#	#	of C code.
#	#
#	my ($cookie, $pg_role) = cookie2pg_role();
#
require 'dbi.pl';

sub cookie2pg_role
{
	return unless $ENV{HTTP_COOKIE} =~ /\bSETSPACE=([^\s;]*)/;

	my $cookie = $1;

	my $q = dbi_select(
		#
		#  Need to indicate we are querying the login schema.
		#  
		#
		#dump	=>	'>/tmp/select-login-id.sql',
		tag	=>	'select-login-cookie',
		sql	=>	<<END
select
	r.pg_role
  from
	http_cookie c,
	http_cookie_age a,
	http_cookie_role r
  where
  	c.id = '$cookie'
	and
	r.cookie_id = c.id
	and
	c.id = a.cookie_id
	and
	c.access_time + a.age > now()
;
END
		#
		#  A background process will update the access_time,
		#  based upon log traffic.
		#
	);
	if (my $row = $q->fetchrow_hashref()) {
		return ($cookie, $row->{pg_role});
	}
	return ($cookie, undef);
}

1;
