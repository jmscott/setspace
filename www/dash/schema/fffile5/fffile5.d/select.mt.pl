#
#  Synopsis:
#	Generate html <select> for fffile5 mime types.
#  Usage:
#	/cgi-bin/fffile5?out=select
#

require 'httpd2.d/common.pl';
require 'dbi-pg.pl';

our %QUERY_ARG;

my $mt = $QUERY_ARG{mt};

print <<END;
<select
  name="mt"
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
> 
 <option value="">--Select Mime Type--</option>
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
	my $mt_db = $r->{mime_type};
	my $mime_type = encode_html_entities($mt_db);;
	my $value_mime_type = encode_url_query_arg($mt_db);
	my $blob_count = $r->{blob_count};

	my $selected_att;
	$selected_att = ' selected="selected"' if $mt eq $mt_db;
	print <<END;
 <option
   value="$value_mime_type"
   $selected_att
 >$mime_type ($blob_count blobs)</option>
END
}
print <<END;
</select>
END
