#  Put a string to a blob, digesting as $ENV{BLOBIO_ALGORITHM}, returning
#  the udig of the blob

sub string2blob
{
	my ($what, $string) = @_;

	my $algo = $ENV{BLOBIO_ALGORITHM};

	die 'environment not defined: BLOBIO_ALGORITHM' unless $algo;
	die 'environment not defined: TMPDIR' unless $ENV{TMPDIR};

	#  put_string2blob() not reentrant!

	our $path = "$ENV{TMPDIR}/put_string2blob.$$";
	die "refuse to overwrite existing temp file: $path" if -e $path;

	my $TMP;
	open($TMP, ">$path") or die "open(>$path) failed: $!";
	END
	{
		unlink($path);
	}

	syswrite($TMP, $_[0]);
	close($TMP) or die "close($path) failed: $!";

	my $EAT;

	my $cmd = "| blobio eat --algorithm $algo --input-path $path";
	my $PIPE;

	#  fetch the digest of the blob file

	open($PIPE, $cmd) or die "open($cmd) failed: $!";
	die "syswrite($cmd) failed: $!"
		unless syswrite($PIPE, $_[0]) == length($_[0])
	;
	my $digest = <$PIPE>;
	close($PIPE) or die "close($cmd) failed: $!";
	chomp $digest;
	die "unexpected blob digest: $digest"
		unless $digest =~ m/^[[:graph:]]{32,128}$/;

	#  give the blob to the server
	$cmd = "blobio give --udig $algo:$digest --input-path $path";
	my $status = system($cmd);
	die "system($cmd) failed: $!" unless $status == 0;

	unlink($path);
}
