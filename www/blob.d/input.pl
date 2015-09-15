#
#  Synopsis:
#	Put html <input> of blob udig
#

our %QUERY_ARG;

my $udig = encode_html_entities($QUERY_ARG{udig});

print <<END;
<input$QUERY_ARG{id_att}$QUERY_ARG{class_att}
	name="udig"
	value="$udig"
/>
END

1;
