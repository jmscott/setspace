#
#  Synopsis:
#	Fetch a blob with value file_mime_type set in header Content-Type.
#
require 'utf82blob.pl';
require 'common-json.pl';
require 'dbi-pg.pl';

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};
my $qh = dbi_pg_select(
		db =>	dbi_pg_connect(),
		tag =>	'select-fffile5-mime',
		argv =>	[
			$blob
		],
		sql =>	q(
SELECT
	mt.mime_type,
	bc.byte_count,
	CASE
	  WHEN
	  	t.title ~ '[[:graph:]]'
	  THEN
	  	t.title
	  ELSE
	  	$1
	END as title
  FROM
  	fffile5.file_mime_type mt
	  JOIN setcore.byte_count bc ON (bc.blob = mt.blob)
	  LEFT OUTER JOIN mycore.title t ON (t.blob = mt.blob)
  WHERE
  	mt.blob = $1::udig
;
));

my $row = $qh->fetchrow_hashref();
unless ($row) {
	print <<END;
Status: 404
Content-Type: text/html

Blob Not Found: $blob
END
	return 1;
}

my $byte_count = $row->{byte_count};
unless ($byte_count =~ /^\d+$/) {
	print <<END;
Status: 500
Content-Type: text/html

Blob Byte Count Not An Integer or Empty: $blob
END
	return 1;
}

my $mime_type = $row->{'mime_type'};
unless ($mime_type =~ /[[:graph:]]/) {
	print <<END;
Status: 500
Content-Type: text/html

Mime Type has No Graphical Chars or Empty: $blob
END
	return 1;
}

my $filename = $row->{'title'};
$filename =~ s/"/_/g;

print <<END;
Status: 200
Content-Type: $mime_type
Content-Disposition: inline;  filename="$filename"
Content-Length: $byte_count

END

#  Note: write the blob

my $SERVICE = $ENV{BLOBIO_SERVICE};
my $GET_SERVICE = $ENV{BLOBIO_GET_SERVICE} ? 
			$ENV{BLOBIO_GET_SERVICE} :
			$SERVICE
;

my $status = system("blobio get --service $GET_SERVICE --udig $blob");

unless ($status == 0) {
	my $pre = "fffile5.d/mime.mt: $$";
	print STDERR "$pre: blobio get failed: exit status=$status\n";
	print STDERR "$pre: blob: $blob\n";
	return 1;
}

#  save the blob fetched and details of search

$mime_type = utf82json_string($mime_type);
my $unix_epoch = time();
$blob = utf82json_string($blob);

my $env = env2json(2);

utf82blob(<<END);
{
	"fffile5.schema.setspace.com": {
		"fffile5-mime-type-find-click": {
			"mime_type": $mime_type,
			"discover-unix-epoch": $unix_epoch,
			"blob": $blob
		}
	},
	"cgi-bin-environment": $env
}
END
1;
