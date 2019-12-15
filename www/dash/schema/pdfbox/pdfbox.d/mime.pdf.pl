#
#  Synopsis:
#	Fetch a blob as a pdf mime type.
#  Note:
#	The pdfbox-full-text-search-click needs to move to a separate
#	cgi-bin widget callable from web page!  Simply displaying a pdf
#	blob triggers a json blob for a web search!
#
#	WTF?  No validation is done on the blob.  In fact, the blob is
#	assumed to exist and be correct.  Terrible.
#
require 'utf82blob.pl';
require 'common-json.pl';

our %QUERY_ARG;

my $udig = $QUERY_ARG{udig};

my $status = system("blobio get --service $ENV{BLOBIO_SERVICE} --udig $udig");

print STDERR "pdfbox.d/blob: blobio get $udig: exit status=$status\n"
	unless $status == 0
;

#  save the blob fetched and details of search

my $q = utf82json_string($QUERY_ARG{q});
my $unix_epoch = time();
$udig = utf82json_string($udig);

my $env = env2json(2);

#  Note: add the array of matching blob?
print STDERR 'pdfbox-full-text-search-click: json: ', utf82blob(<<END), "\n";
{
	"mydash.schema.setspace.com": {
		"pdfbox-full-text-search-click": {
			"discover-unix-epoch": $unix_epoch,
			"pdf_blob": $udig
		}
	},
	"cgi-bin-environment": $env
}
END
;
1;
