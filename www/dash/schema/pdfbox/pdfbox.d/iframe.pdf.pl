#
#  Synopsis:
#	Write html <iframe> of pdf blob.
#  Note:
#	Rename query arg "udig" as "blob" for consistency.
#

require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};

print <<END;
<iframe
  src="/cgi-bin/pdfbox?out=mime.pdf&udig=$blob"
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
></iframe>
END
