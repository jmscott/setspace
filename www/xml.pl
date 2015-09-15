#
#  Synopsis:
#	Helpful xml support routines based on XML
#
use XML::Parser;

#
#  Search for the first child XML element in an array of XML children.
#
sub find_kid
{
	my %arg = @_;
	my (
		$tag,
		$kids,
		$required,
		$what
	) = (
		$arg{tag},
		$arg{kids},
		$arg{required},
		$arg{what}
	);

	die 'find_kid: missing element tag' unless $tag;

	for (my $i = 1;  defined $kids->[$i];  $i += 2) {
		return $kids->[$i + 1] if $kids->[$i] eq $tag;
	}
	if ($required eq 'yes') {
		$what = 'child' unless $what;
		die "$what: can't find element $tag" if $required eq 'yes';
	}
	return undef;
}

sub find_text
{
	my $node = $_[0];
	my $text;

	for (my $i = 1;  defined $node->[$i];  $i += 2) {
		next unless $node->[$i] == 0;
		$text .= $node->[$i + 1];
	}
	return $text;
}

sub text2xml
{
	my $t = $_[0];

	$t =~ s/&/\&amp;/gms;
	$t =~ s/</\&lt;/gms;
	$t =~ s/>/\&gt;/gms;
	$t =~ s/"/\&quot;/gms;
	$t =~ s/'/\&apos;/gms;

	return $t;
}

1;
