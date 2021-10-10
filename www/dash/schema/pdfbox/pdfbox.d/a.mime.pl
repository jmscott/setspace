#
#  Synopsis:
#	Generate an html <a> link to a pdf blob.
#

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};

print <<END;
<a
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
  href="/cgi-bin/schema/pdfbox?out=mime.pdf&blob=$blob"
  title="$blob"
  >$blob</a>
END
