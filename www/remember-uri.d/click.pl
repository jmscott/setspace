#
#  Synopsis:
#	Record a click through on a remembered uri.
#

require 'account.d/common.pl';
require 'xml.pl';
require 'blob.pl';

select STDOUT; $| = 1;		#  flush the output

#
#  Must be logged in to remember a uri;  otherwise, redirect to login page.
#
#  Note:
#  	Unfortunately, if not logged in, then the client must resubmit the
#  	"Remember" request, which is awkward.
#
my ($cookie, $pg_role) = cookie2pg_role();

unless ($pg_role) {
	my $uri = '/login.shtml?err=Please%20Login%20Before%Remembering%20URI';

	#
	#  Expire the cookie.
	#
	print <<END if $ENV{HTTP_COOKIE} =~ /\bSETSPACE=([^;\s]+)/;
Set-Cookie: SETSPACE=;  path=/;  expires=Thu, 01-Jan-1970 00:00:01 GMT;
END
	print <<END;
Status: 303
Location: $uri
\r
END
	cgi2blob(
		status		=>	303,
		location	=>	$uri
	);
}

our %QUERY_ARG;

my ($udig, $uri) = (text2xml($QUERY_ARG{udig}));
my $q = dbi_select(
	db	=>	dbi_connect(),
	tag	=>	'remember-uri-click',
	#dump	=>	'>/tmp/remember-uri-click.sql',
	#trace	=>	15,
	sql	=>	<<END
select
	r.uri
  from
  	remember_uri r
  where
  	r.blob = E'$udig'
END
);

my $row = $q->fetchrow_hashref();
unless ($row) {
	my $l = "/click-err.shtml?err=Link%20Not%20%Found:%20$udig";

	print <<END;
Status: 303
Location: $l

END
	cgi2blob(
		status		=>	303,
		location	=>	$l
	);
}

my $uri = $row->{uri};
$cookie = text2xml($cookie);

#
#  Remember the uri by creating a blob.
#
my $req = text2blob(<<END);
<?xml version="1.0"?>
<setspace>
 <pg-role>$pg_role</pg-role>
 <cookie>$cookie</cookie>
 <remember-uri>
  <click>
   <uri>$uri</uri>
   <udig>$udig</udig>
  </click>
 </remember-uri>
</setspace>
END

print <<END;
Status: 303
Location: $uri

END

cgi2blob(
	'request-udig'	=>	$req,
	status		=>	303,
	location	=>	$uri
);

exit 0;

1;
