#
#  Synopsis:
#	Generate an html <select> of the table of file-mime-stat sorted by count
#

require 'dbi.pl';

our %QUERY_ARG;

my $mime = $QUERY_ARG{mime};
my $name = $QUERY_ARG{id} ? $QUERY_ARG{id} : 'mime';

print <<END;
<select$QUERY_ARG{class_att}$QUERY_ARG{id_att}
  name="$name"
>
 <option value="">-- Select File Mime Type --</option>
END

my $q = dbi_select(
		tag =>	'file-mime-stat-select',
		sql =>	<<END
select
	readable,
	blob_count
  from
  	file_mime_stat
  order by
  	blob_count desc
END
);

while (my $r = $q->fetchrow_hashref()) {
	my (
		$readable,
		$blob_count
	) = (
		$r->{readable},
		$r->{blob_count}
	);
	my $selected = $mime eq $readable ? ' selected="selected"' : '';
	my $value = encode_html_entities($readable);
	my $plural = $blob_count == 1 ? '' : 's';
	print <<END;
 <option$selected value="$value">$value ($blob_count blobs)</option>
END
}

print <<END;
</select>
END

1;
