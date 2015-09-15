#
#  Synopsis
#	Remember a uri and redirect to that uri.
#  Note:
#  	Do not require user to be logged in.
#  	Shouldn't the user be logged in?
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
	my $uri ='/login.shtml?err=Please%20Login%20Before%20Remembering%20URI';

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

my $uri = $QUERY_ARG{uri};
my $xml_uri = text2xml($uri);

#
#  Title is not required.
#  If title is empty, then do not add to xml.
#
my ($title, $title_twig) = text2xml($QUERY_ARG{title});
unless ($title =~ /^\s*$/) {
	$title_twig =<<END;
 <title>$title</title>
END
}
$pg_role = text2xml($pg_role);
$cookie = text2xml($cookie);

#
#  Remember the uri by creating a blob.
#  Shouldn't the full path be
#
#  	/setspace/remember-uri/save
#
#  To be consistent with /setspace/remember-uri/click
#
my $req = text2blob(<<END);
<?xml version="1.0"?>
<setspace>
 <pg-role>$pg_role</pg-role>
 <cookie>$cookie</cookie>
 <remember-uri>
  <uri>$xml_uri</uri>
  $title_twig
 </remember-uri>
</setspace>
END

#
#  We don't re-set the cookie authorization.
#  Should we?
#
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
