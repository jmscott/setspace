#
#  Synopsis:
#	Write <input name="q" value="$q" /> html element
#

our %QUERY_ARG;
my ($q, $value, $name);

if ($q = $QUERY_ARG{q}) {
	$value = sprintf('value="%s"', $q);
}

if ($QUERY_ARG{id}) {
	$name = $QUERY_ARG{id};
} else {
	$name = 'q';
}

print <<END;
<input$QUERY_ARG{id_att}$QUERY_ARG{class_att}
	type="text"
	name="$name"
	$value
/>
END
