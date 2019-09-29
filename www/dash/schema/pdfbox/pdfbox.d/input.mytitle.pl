#
#  Synopsis:
#	Write html <input> of title in table mycore.title
#  Note:
#	Need alert when blob exists but is not in pdfbox.pddocument.
#	Currently only empty title is returned.
#

require 'httpd2.d/common.pl';
require 'dbi-pg.pl';

our %QUERY_ARG;

my $blob = encode_html_entities($QUERY_ARG{blob});

my $qh = dbi_pg_select(
	db =>		dbi_pg_connect(),
	tag =>		'select-input-mytitle',
	argv =>		[
				$blob,
			],
	sql =>		q(
SELECT
	t.title
  FROM
  	pdfbox.pddocument_information pi
	  JOIN mycore.title t ON (t.blob = pi.blob) 
  WHERE
  	pi.blob = $1::udig
;
));

my $title;
if (my $row = $qh->fetchrow_arrayref()) {
	$title = encode_html_entities($row->[0]);
}

print <<END;
<input
  name="title"
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
  value="$title"
/>
END
