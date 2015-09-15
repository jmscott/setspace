#
#  Synopsis:
#	Clean up a tsquery entered from an html form.
#  Note:
#	Words separated by white space are reconnected with logical 'and'.
#	For example,
#
#		dallas cowboy
#
#	becomes
#		dallas & cowboy.
#
#	Parenthesis are not allowed, yet.
#
#
sub query2ts
{
	my $q = $_[0];

	#
	#  Strip out non relavent characters
	#
	$q =~ s/[^\w\s!&|]/ /g;

	#
	#  Strip white space following an operator
	#
	$q =~ s/([!&|])\s+/$1/g;

	#
	#  Strip single character words
	#
	#  Note:
	#  	Ought to preserve single letter as part of hyphenated word.
	#  	For example 'k-hitting set' probably ought to preserver the k.
	#
	#
	$q =~ s/\b\w\b/ /g;

	#
	#  Strip out consecutive operators: !&|
	# 
	$q =~ s/[!&|][!&|]+//g;

	#
	#  Compress white space into single space
	#
	$q =~ s/\s\s+/ /g;

	#
	#  And together space separated terms.
	#
	#  Can the global loop be eliminated?
	#
	while ($q =~ m/(?:!?\w+) (?:!?\w+)/) {
		$q =~ s/(!?\w+) (!?\w+)/$1 \& $2/;
	}

	return $q;
}

return 1;
