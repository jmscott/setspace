#
#  Synopsis:
#	Write html <iframe> of pdf blob.
#

require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};

print <<END;
<iframe
  src="/cgi-bin/schema/pdfbox?out=mime.pdf&blob=$blob"
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
></iframe>
END
