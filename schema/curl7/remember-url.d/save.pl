#
#  Synopsis
#	Remember a url and redirect to that url.
#  Note:
#  	Do not require user to be logged in.
#  	Shouldn't the user be logged in?
#

require 'account.d/common.pl';
require 'xml.pl';
require 'blob.pl';

select STDOUT; $| = 1;		#  flush the output

#
#  Must be logged in to remember a url;  otherwise, redirect to login page.
#
#  Note:
#  	Unfortunately, if not logged in, then the client must resubmit the
#  	"Remember" request, which is awkward.
#
my ($cookie, $pg_role) = cookie2pg_role();

unless ($pg_role) {
	my $url ='/login.shtml?err=Please%20Login%20Before%20Remembering%20URI';

	#
	#  Expire the cookie.
	#
	print <<END if $ENV{HTTP_COOKIE} =~ /\bSETSPACE=([^;\s]+)/;
Set-Cookie: SETSPACE=;  path=/;  expires=Thu, 01-Jan-1970 00:00:01 GMT;
END
	print <<END;
Status: 303
Location: $url
\r
END
	cgi2blob(
		status		=>	303,
		location	=>	$url
	);
}

our %QUERY_ARG;

my $url = $QUERY_ARG{url};
my $xml_url = text2xml($url);

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
#  Remember the url by creating a blob.
#  Shouldn't the full path be
#
#  	/setspace/remember-url/save
#
#  To be consistent with /setspace/remember-url/click
#
my $req = text2blob(<<END);
<?xml version="1.0"?>
<setspace>
 <pg-role>$pg_role</pg-role>
 <cookie>$cookie</cookie>
 <remember-url>
  <url>$xml_url</url>
  $title_twig
 </remember-url>
</setspace>
END

#
#  We don't re-set the cookie authorization.
#  Should we?
#
print <<END;
Status: 303
Location: $url

END

cgi2blob(
	'request-udig'	=>	$req,
	status		=>	303,
	location	=>	$url
);

exit 0;

1;
