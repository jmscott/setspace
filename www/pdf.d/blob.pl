#
#  Synopsis:
#	Fetch a blob as a pdf mime type with title as content disposition. 
#  Note:
#	WTF?  No validation is done on the blob.  In fact, the blob is
#	assumed to exist and be correct.  Terrible.
#
require 'dbi.pl';
require 'account.d/common.pl';

our %QUERY_ARG;

#
#  Can't fetch blob unless logged.
#
#  Note:
#	If not logged, then write an http Status 204, indicating no content and,
#	if I(jmscott) am interpreting the spec correctly, that the client 
#  	should not change any metadata about the link.  Is this better than
#  	status 404?
#
my $pg_role = cookie2pg_role();
unless ($pg_role) {
	print <<END;
Status: 204
\r
END
	return 1;
}

my $udig = $QUERY_ARG{udig};

my $service = $ENV{BLOBIO_SERVICE} ? $ENV{BLOBIO_SERVICE} : 'localhost:1797';

my $q = dbi_select(
	db	=>	dbi_connect(),
	#dump	=>	'>/tmp/pdf-blob.sql',
	tag	=>	'pdf-blob-detail',
	sql	=>	<<END
select
	fm.readable as "content_type",
	(
		(mt.value is not null or t.value is not null)
		or
		mt.value is null 
	) as "add_title",
	coalesce(
		mt.value,		/* my title */
		t.value,		/* public title */
		pit.value,		/* pdfinfo_title */
		'$udig'
	) as "title"
  from
  	blob b
	  left outer join file_mime fm on (b.id = fm.blob)
	  left outer join my_title mt on (
	  	b.id = mt.blob
		and
		mt.pg_role = '$pg_role'
	  )
	  left outer join title t on (b.id = t.blob)
	  left outer join pdfinfo_title pit on (b.id = pit.blob)
  where
  	b.id = '$udig'
END
);

my $h;

#
#  We don't have the document, so 404 'em.
#
unless ($h = $q->fetchrow_hashref()) {
	print <<END;
Status: 404
\r
END
	return 1;
}

my $add_title = $h->{add_title};
print <<END if $h->{content_type};
Content-Type: $h->{content_type}
END

#
#  Build http mime types for file name, description, etc.
#
my $title = $h->{title};
$title = $udig unless $title =~ /[[:alnum:]]/;
$title =~ s/"/\\"/g;			#  strip quote chars
$title =~ s/[^[:print]]/ /g;		#  strip non printable chars
$title =~ s/[\n\r\f]+/ /g;		#  map nl/cr/ff to space
#
#  Note:
#  	Mozilla lose file name when inline;  attachment seems
#  	to work ok;  might consider browser snooping
#
print <<END;
Content-Description: $title
Content-Disposition: inline;  filename="$title.pdf"
END

#
#  Need to add ETag!
#
print <<END unless $add_title;
Cache-Control: max-age=5184000, public, private
END

print <<END;
\r
END

#
#  WTF: we assume the blob exists. Really lazy implementation.
#
my $exiftool;
if ($add_title eq 't') {
	my $t = $title;
	$t =~ s/'/\\'/g;
	$exiftool = " | exiftool - -Title='$t' -Producer='$udig' -o -";
}
system("blobio get --service $service --udig $udig $exiftool");

1;
