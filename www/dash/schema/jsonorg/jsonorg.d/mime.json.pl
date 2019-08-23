#
#  Synopsis:
#	Fetch a blob as a json mime type.
#  Note:
#	Need to generalize into cgi-bin for all of dashboard, where the mime
#	type, content length and title are derived from the relational
#	database, as well as gzipping.
#
our %QUERY_ARG;

my $udig = $QUERY_ARG{udig};

my $status = system("blobio get --service $ENV{BLOBIO_SERVICE} --udig $udig");

print STDERR "jsonorg.d/blob: blobio get $udig: exit status=$status\n"
	unless $status == 0
;

1;
