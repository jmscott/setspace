#
#  Push text to a blobio server.
#
#  Note:
#       When will the perl interface to libblobio be written?
#
sub utf82blob
{
	my ($IN, $OUT);


	open2(\*OUT, \*IN, 'bio-put-stdin') or
				die "utf82blob: open2() failed: exit status=$!";

	syswrite(IN, $_[0] . "\n");
	close(IN) or die "utf82blob: close(IN) failed: $!";
	my $udig = <OUT>;
	chomp $udig;
	die "bio-put-stdin: unexpected udig: $udig"
		unless $udig =~ /^[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}$/;
	return $udig;
}

1;
