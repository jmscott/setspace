#
#  Synopsis:
#	Write html <select> of query types: key|phrase|fts
#

require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $qtype = decode_url_query_arg($QUERY_ARG{qtype});

my $key_selected = ' selected' if $qtype eq 'key'; 
my $phrase_selected = ' selected' if $qtype eq 'phrase'; 
my $fts_selected = ' selected' if $qtype eq 'fts'; 

print <<END;
<select
  name="qtype"
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>
 <option value="key"$key_selected>Keyword Search</option>
 <option value="phrase"$phrase_selected>Phrase Search</option>
 <option value="fts"$fts_selected>Full Text Search</option>
</select>
END
