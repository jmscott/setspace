#
#  Synopsis:
#	Generate an html <a> link to a pdf blob.
#  Note:
#	Need to standardize of either "blob" or "udig" but not both in
#	query arguments to various cgi-bin scripts in schema/pdfbox.
#
#  https://dash.stage.setspace.com/cgi-bin/pdfbox?out=mime.pdf&udig=bc160:9ebefc25988794066c7df16d2f0ad048fefdb36f

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};

print <<END;
<a
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
  href="/cgi-bin/pdfbox?out=mime.pdf&udig=$blob"
  b-
  title="$blob"
  >$blob</a>
END
