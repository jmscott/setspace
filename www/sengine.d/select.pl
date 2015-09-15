#
#  Synopsis:
#	html <select> of popular search engines.
#
require 'sengine.d/common.pl';

our (%QUERY_ARG, %SEARCH_ENGINE);

#
#  The cookie SETSPACE_SENGINE indicates which search engine to choose.
#
my $eng = $QUERY_ARG{eng};
unless ($eng) {
	$eng = $1 if $ENV{HTTP_COOKIE} =~ /\bSETSPACE_SENGINE=(\w+)/;
}

print <<END;
<select$QUERY_ARG{id_att}$QUERY_ARG{class_att}
  name="eng"
>
 <option value="">--Select a Search Engine--</option>
END

for my $ogk (sort keys %SEARCH_ENGINE) {
	my $og = $SEARCH_ENGINE{$ogk};

	print <<END;
 <optgroup label="$ogk">
END
	#
	#  Put the <option label="Label">Value</value>
	#
	for my $ok (sort keys %{$og}) {

		my $o = $og->{$ok}->[0];
		my $selected;

		$selected = ' selected="selected"' if $ok eq $eng;
		print <<END;
  <option$selected
    label="$o"
    value="$ok"
  >$ogk - $o</option>
END
	}
	print <<END;
 </optgroup>
END
}

print <<END;
</select>
END

1;
