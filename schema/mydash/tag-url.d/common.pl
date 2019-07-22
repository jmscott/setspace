#
#  Synopsis:
#	common routines for tag-url
#
use strict;
use utf8;
use IPC::Open2;

#  Code lifted from JSON-Tiny
my %ESCAPE = (
	'"'     => '"',
	'\\'    => '\\',
	'/'     => '/',
	'b'     => "\x08",
	'f'     => "\x0c",
	'n'     => "\x0a",
	'r'     => "\x0d",
	't'     => "\x09",
	'u2028' => "\x{2028}",
	'u2029' => "\x{2029}"
);

my %REVERSE = map { $ESCAPE{$_} => "\\$_" } keys %ESCAPE;

for(0x00 .. 0x1f) {
	my $packed = pack 'C', $_;
	$REVERSE{$packed} = sprintf '\u%.4X', $_
			unless defined $REVERSE{$packed};
}

sub utf82json
{
	my $str = shift;
	$str =~ s!([\x00-\x1f\x{2028}\x{2029}\\"/])!$REVERSE{$1}!gs;
	return "\"$str\"";
}

sub env2json()
{
	my $json = "{";
	for (sort keys %ENV) {
		my $e = utf82json($_);
		my $v = utf82json($ENV{$_});
		$json .=<<END;
		"$e": "$v",
END
	}
	$json =~ s/,//;
	return $json . '}';
}

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
