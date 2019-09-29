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

#  strip compress white space
$title =~ s/^[[:space:]]{2,}/ /g;
$title =~ s/^[[:space:]+]|[[:space:]]+$//g;

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
	print STDERR "post.mytitle.pl: $error_403";
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
print STDERR "post.mytitle: json request blob: $request_blob";

#  pause while title syncs, returning uri of request
sleep 2;
print <<END;
Status: 303
Location: $ENV{HTTP_REFERER}

END
