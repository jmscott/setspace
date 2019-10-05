#
#  Synopsis:
#	Write utf8 text of first page of a pdf file.
#

use utf8;

require 'dbi-pg.pl';
require 'httpd2.d/common.pl';

our %QUERY_ARG;

my $blob = $QUERY_ARG{blob};
my $lim = $QUERY_ARG{lim};

my $qh = dbi_pg_select(
	db =>   dbi_pg_connect(),
	tag =>  'select-pdfbox-pdf-page1',
	argv => [
                        $blob,
			$lim
                ],
        sql =>  q(
SELECT
	substring(u8.txt, 1, $2) ||
	  CASE
	    WHEN
		length(substring(u8.txt, 1, $2)) < length(u8.txt)
	    THEN
	  	' ...'
	    ELSE
	  	''
	  END
  FROM
  	pdfbox.extract_pages_utf8 pg
	  JOIN pdfbox.page_text_utf8 u8 ON (u8.pdf_blob = pg.pdf_blob)
  WHERE
  	pg.pdf_blob = $1
	and
	pg.page_number = 1
;
));

print encode_html_entities($qh->fetchrow_arrayref()->[0]);
