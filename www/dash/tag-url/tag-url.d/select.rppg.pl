#
#  Synopsis:
#  	Generate a <select> of options for ordering pdf search results
#  Blame:
#  	jmscott@setspace.com
#

our %QUERY_ARG;

my @OPTION =
(
	'10',		'10 Results',
	'100',		'100 Results',
	'1000',		'1000 Results',
	'10000',	'10000 Results'
);

#
#  What about pulling the value of rppg from the COOKIE?
#
my $rppg = $QUERY_ARG{rppg};

print <<END;
<select$QUERY_ARG{class_att}$QUERY_ARG{id_att}
  name="rppg"
>
 <option value="">--Select an Results per Page--</option>
END

for (my $i = 0, my $limit = $#OPTION;  $i < $limit;  $i += 2) {
	my ($tag, $title) = @OPTION[$i, $i + 1];

	my $selected = ($tag eq $rppg) ? ' selected="selected"' : '';

	print <<END;
 <option$selected
   value="$tag">$title</option>
END
}

print <<END;
</select>
END
