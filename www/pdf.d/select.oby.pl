#
#  Synopsis:
#  	Generate a <select> of options for ordering pdf search results
#  Blame:
#  	jmscott@setspace.com
#

our %QUERY_ARG;

my @OPTION =
(
	'tscd',		'Word Covering, Logarithmic Body Density',
	'dtimd',	'Discovery Time - Most Recent',
	'dtima',	'Discovery Time - Oldest',
	'pgcoa',	'Page Count - Increasing',
	'pgcod',	'Page Count - Decreasing',
	'rand',		'Random'
);

my $oby = $QUERY_ARG{oby};

print <<END;
<select$QUERY_ARG{class_att}$QUERY_ARG{id_att}
  name="oby"
>
 <option value="">--Select an Ordering--</option>
END

for (my $i = 0, my $limit = $#OPTION;  $i < $limit;  $i += 2) {
	my ($tag, $title) = @OPTION[$i, $i + 1];

	my $selected = ($tag eq $oby) ? ' selected="selected"' : '';

	print <<END;
 <option$selected
   value="$tag">$title</option>
END
}

print <<END;
</select>
END
