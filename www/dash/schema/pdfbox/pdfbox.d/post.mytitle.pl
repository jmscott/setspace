#
#  Synopsis:
#	Redirect a full text search to pdfbox/index page seeded with query.
#
use utf8;

require 'utf82blob.pl';
require 'common-json.pl';

our %POST_VAR;

my $blob = utf82json_string($POST_VAR{blob});
die 'POST_VAR: blob is empty' if $blob eq '""';
my $title = $POST_VAR{title};

#  strip leading/trailing white space
$title =~ s/^[[:space:]]*|[[:space:]]*$//g;

#  compress white space
$title =~ s/[[:space:]]+/ /g;

my $error_403;
if (length($title) == 0) {
	$error_403 = 'Title is empty';
} elsif (length($title) > 255) {
	$error_403 = 'Submitted title > 255 UTF8 characters';
} elsif ($title !~ m/[[:graph:]]/) {
	$error_403 = 'No graphics characters in title';
} elsif ($title =~ m/[[:cntrl:]]/) {
	$error_403 = 'Control character in title';
}

if ($error_403) {
	print STDERR "post.mytitle.pl: $error_403\n";
	print <<END;
Status: 403
Content-Type: text/plain

$error_403
END
	return 1;
}

$title = utf82json_string($title);
my $env = env2json(2);
my $request_epoch = time();

my $request_blob = utf82blob(<<END);
{
	"mycore.schema.setspace.com": {
		"title": {
			"blob": $blob,
			"title": $title
		}
	},
	"mydash.schema.setspace.com": {
		"mycore.title": {
			"blob": $blob,
			"title": $title
		}
	},
	"request-unix-epoch": $request_epoch,
	"cgi-bin-environment": $env
}
END
print STDERR "post.mytitle: json request blob: $request_blob\n";

#  pause while title syncs, returning uri of request
my $cmd = "spin-wait-blob jsonorg.jsonb_255 blob 4 $request_blob";
unless (system($cmd) == 0) {
	my $status = $?;
	print STDERR 'post.mytitle: ',
	             "system(spin-wait-blob) failed: exit status=$status\n";
	print STDERR "post.mytitle: $cmd\n";
	$status = ($status >> 8) & 0xFF;
	if ($status > 1) {
		print <<END;
Status: 500
Content-Type: text/plain

ERROR: unexpected reply for json request: status=$status: $request_blob
END
	} elsif ($status == 1) {
		print <<END;
Status: 503
Content-Type: text/plain

ERROR: no json request blob in sql database after 4sec: $request_blob
END
	}
	return 1;
}

print <<END;
Status: 303
Location: $ENV{HTTP_REFERER}

END
