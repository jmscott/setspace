#
#  Synopsis:
#	Write html <pre> of all json blob.
#  Usage:
#	/cgi-bin/schema/jsonorg?out=pre&blob=sha:29bded2734...
#
use Time::HiRes qw(gettimeofday);

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};

print "<pre$QUERY_ARG{id_att}$QUERY_ARG{class_att}>";
my $service = $ENV{BLOBIO_GET_SERVICE};
$service = $ENV{BLOBIO_SERVICE} unless $service;

my $status = system("blobio get --udig $blob --service $service");

if ($status == 1) {
	print "JSON Blob not found: $blob";
} elsif ($status > 0) {
	print "ERROR: fetching JSON blob: exit status: $status: $blob";
}

1;
