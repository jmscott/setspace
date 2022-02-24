#
#  Synopsis:
#	Generate html <select> for fffile5 mime types.
#  Usage:
#	/cgi-bin/fffile5?out=select
#

require 'httpd2.d/common.pl';
require 'dbi-pg.pl';

our %QUERY_ARG;

my $topk = $QUERY_ARG{topk};

print <<END;
<select
  name="topk"
  $QUERY_ARG{id_att}
  $QUERY_ARG{class_att}
> 
 <option value="">--Select Top Object Key--</option>
END

my $q = dbi_pg_select(
	db =>		dbi_pg_connect(),
	tag =>		'jsonorg-select-topk',
	argv =>		[],
	sql =>		q(
SELECT
	object_key,
	doc_count
  FROM
  	jsonorg.jsonb_object_keys_stat
  ORDER BY
  	doc_count desc
;
));

while (my $r = $q->fetchrow_hashref()) {
	my $topk_db = $r->{object_key};
	my $topk_text = encode_html_entities($topk_db);;
	my $value_object_key = $topk_db;
	my $doc_count = $r->{doc_count};

	my $selected_att;
	$selected_att = ' selected="selected"' if $topk eq $topk_db;
	print <<END;
 <option
   value="$value_object_key"
   $selected_att
 >$topk_text (about $doc_count blobs)</option>
END
}
print <<END;
</select>
END
