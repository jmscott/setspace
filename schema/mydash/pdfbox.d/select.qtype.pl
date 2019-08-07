#
#  Synopsis:
#	Write html <select> of query types: key|phrase|fts
#

require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $qtype = decode_url_query_arg($QUERY_ARG{qtype});

my $key_selectd = ' selected="selected"' if $qtype eq 'key'; 
my $phrase_selectd = ' selected="selected"' if $qtype eq 'phrase'; 
my $fts_selectd = ' selected="selected"' if $qtype eq 'fts'; 

print <<END;
<select
  name="qtype"
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
>
 <option value="key"$key_selectd>Keyword</option>
 <option value="phrase"$phrase_selectd>Phrase</option>
 <option value="fts"$fts_selectd>Full Text Search</option>
</select>
END
