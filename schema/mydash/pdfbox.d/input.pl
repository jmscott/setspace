#
#  Synopsis:
#	Write html <input> of query string.	
#

require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $q = encode_html_entities($QUERY_ARG{q});

print <<END;
<input
  name="q"
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
  value="$q"
/>
END
