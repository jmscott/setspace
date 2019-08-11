#
#  Synopsis:
#	Write html <div> if the err queray argument exists.
#

our %QUERY_ARG;

my $err = $QUERY_ARG{err};

return 1 unless length($err) > 0 && $err =~ /[[:graph:]]/;

$err = encode_html_entities($err);

print <<END;
<div$QUERY_ARG{id_att}
  class="err $QUERY_ARG{class}"
>
  <h1>ERROR</h1>
  <p>$err</p>
</div>
END

1;
