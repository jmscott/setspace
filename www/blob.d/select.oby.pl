#
#  Synopsis:
#  	Generate an html <select> of options for ordering blob search results
#  Blame:
#  	jmscott@setspace.com
#

our %QUERY_ARG;

my @OPTION =
(
	'dtime',	'Most Recent Discovery Time',
	'adtim',	'Oldest Discovery Time',
	'bcnta',	'Smallest to Largest Byte Count',
	'bcntd',	'Largest to Smallest Byte Count',
	'rand',		'Random'
);

my $oby = $QUERY_ARG{oby};

print <<END;
<select$QUERY_ARG{class_att}$QUERY_ARG{id_att}
  name="oby"
>
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
