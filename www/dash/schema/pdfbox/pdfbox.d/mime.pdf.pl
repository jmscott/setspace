#
#  Synopsis:
#	Fetch a blob as a pdf mime type.
#  Note:
#	WTF?  No validation is done on the blob.  In fact, the blob is
#	assumed to exist and be correct.  Terrible.
#
our %QUERY_ARG;

my $udig = $QUERY_ARG{udig};

my $status = system("blobio get --service $ENV{BLOBIO_SERVICE} --udig $udig");

print STDERR "pdfbox.d/blob: blobio get $udig: exit status=$status\n"
	unless $status == 0
;

1;
