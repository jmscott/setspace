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
WITH txt_out AS (
 SELECT
	substring(u8.txt, 1, $2) AS txt,
	length(substring(u8.txt, 1, $2)) < $2 AS is_truncated
  FROM
  	pdfbox.extract_pages_utf8 pg
	  JOIN pdfbox.page_text_utf8 u8 ON (u8.pdf_blob = pg.pdf_blob)
  WHERE
  	pg.pdf_blob = $1
	and
	pg.page_number = 1
) SELECT
	txt || (

);

print encode_html_entities($qh->fetchrow_arrayref()->[0]);
