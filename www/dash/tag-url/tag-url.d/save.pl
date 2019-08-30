#
#  Synopsis
#	tag a url and redirect to that url.
#  Note:
#  	Do not require user to be logged in.
#  	Shouldn't the user be logged in?
#

require 'tag-url.d/common.pl';

our %QUERY_ARG;

my $url = utf82json_string($QUERY_ARG{url});
my $title = utf82json_string($QUERY_ARG{title});
my $unix_epoch = time();

select STDOUT; $| = 1;		#  flush the output

my $env = env2json(2);
my $json =<<END;
{
	"mydash.schema.setspace.com": {
		"tag-url": {
			"url": $url,
			"title": $title,
			"discover-unix-epoch": $unix_epoch
		}
	},
	"cgi-bin-environment": $env
}
END

my $udig = utf82blob($json);
print STDERR "tag-url: json request: udig=$udig\n";

print <<END;
Status: 303
Location: $QUERY_ARG{url}

END

1;
