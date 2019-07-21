use strict;
use utf8;

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

1;
