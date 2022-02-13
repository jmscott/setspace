#!/usr/bin/env perl
#
#  Synopsis:
#	Convert a single message mail box file (elm) to json
#  Usage:
#	bio-cat btc20:d8317137cd727149c5a44b8b0b093246899d100b | eml2json
#
use Mail::Box::Parser;

sub escape_json
{
        my $s = $_[0];

        $s =~ s/\n/\\n/g;
        $s =~ s/\t/\\t/g;
        $s =~ s/\f/\\f/g;
        $s =~ s/\r/\\r/g;
        $s =~ s/\x08/\\b/g;             # backspace
        $s =~ s/"/\\"/g;
        $s =~ s/'/\\'/g;
        return $s;
}

my $p = Mail::Box::Parser->new(
	file => \*STDIN,
) or die "Mail::Box::Parser->new failed: $!";

my ($where, @header)  = $p->readHeader();
my $header_count = scalar(@header);

print <<END;
{
	"where": $where,
	"header_count": $header_count,
	"header": [
END

for (my $i = 0;  $i < $header_count;  $i++) {
	my $h = $header[$i];
	my $f = escape_json($h->[0]);
	my $v = escape_json($h->[1]);
	print "\t\t\t", '["', $f, '", "', $v, '"]';
	print ',' if $i + 1 < $header_count;
	print "\n";
}

print <<END;
	]
}
END
