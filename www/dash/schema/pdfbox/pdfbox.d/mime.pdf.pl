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
require 'dbi-pg.pl';

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};
my $qh = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-mime-pdf',
		argv =>	[
			$blob
		],
		sql =>	q(
SELECT
	bc.byte_count,
	CASE
	  WHEN
	  	myt.title ~ '[[:graph:]]'
	  THEN
	  	myt.title
	  WHEN
	  	pi.title ~ '[[:graph:]]'
	  THEN
	  	pi.title
	  ELSE
		$1
	END AS title
  FROM
  	pdfbox.pddocument_information pi
	  JOIN setcore.service s ON (s.blob = pi.blob)
	  JOIN setcore.byte_count bc ON (bc.blob = pi.blob)
	  LEFT OUTER JOIN mycore.title myt ON (myt.blob = pi.blob)
  WHERE
  	pi.blob = $1::udig
;
));

my $row = $qh->fetchrow_hashref();
unless ($row) {
	print <<END;
Status: 404
Content-Type: text/html

PDF not found: $blob
END
	return;
}

my $filename = $row->{'title'};
my $content_length = $row->{'byte_count'};
$filename =~ s/"/_/g;

print <<END;
Content-Type: application/pdf
Content-Disposition: inline;  filename="$filename"
Content-Length: $content_length

END

#  Note:  need rewrite pdf with title spliced into header.  details.

my $SERVICE = $ENV{BLOBIO_SERVICE};
my $GET_SERVICE = $ENV{BLOBIO_GET_SERVICE} ? 
			$ENV{BLOBIO_GET_SERVICE} :
			$SERVICE
;

my $status = system("blobio get --service $GET_SERVICE --udig $blob");

print STDERR "pdfbox.d/blob: blobio get $blob: exit status=$status\n"
	unless $status == 0
;

#  save the blob fetched and details of search

my $q = utf82json_string($QUERY_ARG{q});
my $unix_epoch = time();
$blob = utf82json_string($blob);

my $env = env2json(2);

print STDERR 'pdfbox-full-text-search-click: json: ', utf82blob(<<END), "\n";
{
	"mydash.schema.setspace.com": {
		"pdfbox-full-text-search-click": {
			"discover-unix-epoch": $unix_epoch,
			"pdf_blob": $blob
		}
	},
	"cgi-bin-environment": $env
}
END
;
1;
