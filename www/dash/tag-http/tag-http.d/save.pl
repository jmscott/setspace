#
#  Synopsis
#	tag an http/s web page and redirect to that page.
#
require 'common-json.pl';
require 'utf82blob.pl';

select STDOUT; $| = 1;		#  flush the output

our %QUERY_ARG;

my $url = utf82json_string($QUERY_ARG{url});
my $title = utf82json_string($QUERY_ARG{title});
my $unix_epoch = time();

my $env = env2json(2);
my $json =<<END;
{
	"mydash.schema.setspace.com": {
		"tag-http": {
			"url": $url,
			"title": $title,
			"discover-unix-epoch": $unix_epoch
		}
	},
	"cgi-bin-environment": $env
}
END

my $udig = utf82blob($json);
print STDERR "tag-http: json request: udig=$udig\n";

print <<END;
Status: 303
Location: $QUERY_ARG{url}

END

1;
