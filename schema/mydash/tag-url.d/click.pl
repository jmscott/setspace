#
#  Synopsis:
#	Record a click through and tag blob as "Tagged".
#  Note:
#	Why not tag as label on the button or at least add tag as query
#	argument?
#

require 'account.d/common.pl';
require 'xml.pl';
require 'blob.pl';

select STDOUT; $| = 1;		#  flush the output

#
#  Must be logged in to tag a url;  otherwise, redirect to login page.
#
#  Note:
#  	Unfortunately, if not logged in, then the client must resubmit the
#  	"Tag" request, which is awkward.
#
my ($cookie, $pg_role) = cookie2pg_role();

unless ($pg_role) {
	my $uri = '/login.shtml?err=Please%20Login%20Before%Tagging%20URI';

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
	tag	=>	'tag-url-click',
	#dump	=>	'>/tmp/tag-url-click.sql',
	#trace	=>	15,
	sql	=>	<<END
select
	url
  from
  	tag_url
  where
  	blob = E'$udig'
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
#  Tag the uri by creating a json blob.
#
#  Note:
#	Where is the title?
#
my $req = text2blob(<<END);
{
	"schema.setspace.com": "mycore.setspace.com",
	"apache-env" {
		"HTTP_HOST":	"$ENV{HTTP_HOST}",
		"HTTP_REFERER":	"$ENV{HTTP_REFERER}",
		"REMOTE_ADDR":	"$ENV{REMOTE_ADDR}",
		"QUERY_STRING":	"$ENV{QUERY_STRING}",
		"SCRIPT_NAME":	"$ENV{SCRIPT_NAME}",
		"AUTH_TYPE":	"$ENV{AUTH_TYPE}"
	}
	"pg_role": "$pg_role",
	"url": "$url"
}
END

print <<END;
Status: 303
Location: $uri

END

exit 0;

1;
