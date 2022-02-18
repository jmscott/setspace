#
#  Synopsis:
#	Generate html <select> for contents of table
#  Usage:
#	/cgi-bin/fffile5?out=select
#

require 'httpd2.d/common.pl';
require 'dbi-pg.pl';

our %QUERY_ARG;

print <<END;
<select $QUERY_ARG{id_att}$QUERY_ARG{class_att}>
 <option value="">--Select Mime Type--</select>
END

my $q = dbi_pg_select(
	db =>		dbi_pg_connect(),
	tag =>		'fffile5-select',
	argv =>		[],
	sql =>		q(
SELECT
	mime_type,
	blob_count
  FROM
  	fffile5.file_mime_type_stat
  ORDER BY
  	blob_count desc
;
));

while (my $r = $q->fetchrow_hashref()) {
	my $mime_type = encode_html_entities($r->{mime_type});
	my $value_mime_type = encode_url_query_arg($r->{mime_type});
	my $blob_count = $r->{blob_count};
	print <<END;
 <option value="$value_mime_type">$mime_type ($blob_count blobs)</option>
END
}
print <<END;
</select>
END
