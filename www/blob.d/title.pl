#
#  Synopsis:
#	Generate an html <title> suitable for describing the blob. 
#

require 'account.d/common.pl';
require 'dbi.pl';

our %QUERY_ARG;
my $udig = $QUERY_ARG{udig};

return 1 unless $udig;

print <<END;
<title$QUERY_ARG{id_att}>Blob Detail:
END

my $pg_role = cookie2pg_role();
my $q = dbi_select(
		tag	=>	'blob-dl',
		#dump	=>	'>/tmp/blob-title.sql',
		db	=>	dbi_connect(),
		sql	=>	<<END
select
	coalesce(
		mt.value,
		t.value,
		pt.value
	) as "title"
  from
	blob b
  	  left outer join my_title mt on (
	  	mt.blob = b.id
		and
		mt.pg_role = '$pg_role'		-- hmm, could be empty role?
	  )
  	  left outer join title t on (t.blob = b.id)
  	  left outer join pdfinfo_title pt on (pt.blob = b.id)
  where
  	b.id = '$udig'
END
);

my $title;
if (my $row = $q->fetchrow_hashref()) {
	$title = $row->{title};
	$title = $udig unless $title;
} else {
	$title = $udig;
}

print encode_html_entities($title), '</title>';

1;
