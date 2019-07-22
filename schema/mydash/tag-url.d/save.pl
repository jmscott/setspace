#
#  Synopsis
#	tag a url and redirect to that url.
#  Note:
#  	Do not require user to be logged in.
#  	Shouldn't the user be logged in?
#

require 'tag-url.d/common.pl';

our %QUERY_ARG;

my $url = utf82json($QUERY_ARG{url});
my $title = utf82json($QUERY_ARG{title});

select STDOUT; $| = 1;		#  flush the output

my $env = env2json("environment");
my $json =<<END;
{
	"schema.setspace.com": "mydash.schema.setspace.com",
	"url": \"$url\"",
	"title": \"$title\"",
	"environment":
$env
}
END

my $udig = utf82blob($json);
print STDERR "tag-url.save: udig=$udig\n";

print <<END;
Status: 303
Location: $url

END

1;
