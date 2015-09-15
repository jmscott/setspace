#
#  Synopsis:
# 	Generate <input> of current search query in argument named 'q'.
#

our %QUERY_ARG;

my $q = encode_html_entities($QUERY_ARG{q});

print <<END;
<input$QUERY_ARG{class_att}$QUERY_ARG{id_att}
  name="q"
  value="$q"
/>
END

1;
