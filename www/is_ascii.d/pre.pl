#
#  Synopsis:
#	Generate an html <pre> that is a hex dump of the blob.
#  Note:
#	Sloppy about verifying the correctness of the blob.
#
our %QUERY_ARG;

my $udig = $QUERY_ARG{udig};

my $service = $ENV{BLOBIO_SERVICE} ? $ENV{BLOBIO_SERVICE} : 'localhost:1797';

print <<END;
<pre$QUERY_ARG{class_att}$QUERY_ARG{id_att}>
END

#
#  WTF: we assume the blob exists service wise, but are too lazy to verify.
#
my $B;
open($B, "blobio get --service $service --udig $udig |") or
		die "blobio get --service $service --udig $udig |";

my $status;
my $buf;
while (<$B>) {
	print encode_html_entities($_);
}
close($B);
print <<END;
</pre>
END

1;
