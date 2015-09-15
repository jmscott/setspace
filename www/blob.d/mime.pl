#
#  Synopsis:
#	Fetch a blob, setting mime content type and size
#  Note:
#	WTF?  No validation is done on the blob.  In fact, the blob is
#	assumed to exist and be correct.  Terrible.
#
#	Also needs support for etag.
#
require 'blob.pl';
require 'dbi.pl';
require 'account.d/common.pl';

our %QUERY_ARG;

#
#  Not Found if user not logged in.
#  We lie to client so as not to leak info about blob.
#
my $pg_role = cookie2pg_role();
unless ($pg_role) {
	print <<END;
Status: 404
\r
END
	return 1;
}

my $udig = $QUERY_ARG{udig};

my $service = $ENV{BLOBIO_SERVICE} ? $ENV{BLOBIO_SERVICE} : 'localhost:1797';

my $q = dbi_select(
	db	=>	dbi_connect(),
	tag	=>	'blob-mime',
	#dump	=>	'>/tmp/blob-mime.sql',
	sql	=>	<<END
select
	b.id,
	bc.answer as "content_size",
	fm.readable as "content_type"
  from
  	blob b
	  left outer join byte_count bc on (bc.blob = b.id)
	  left outer join file_mime fm on (fm.blob = b.id)
  where
  	b.id = '$udig'
;
END
);

my $r = $q->fetchrow_hashref();
unless ($r) {
	print <<END;
Status: 204
\r
END
	return ;
}

my $content_type = defined $r->{content_type} ?
			$r->{content_type} :
			'application/octet-stream';
;

#
#  Blob exists, so set cache age to forever.
#  What about etags?
#
print <<END;
Content-Type: $content_type
Cache-Control: max-age=5184000, public, private
END

print <<END if $r->{content_length};
Content-Length: $r->{content_length}
END

print <<END;
\r
END

#
#  WTF: we assume the blob exists service wise, but are too lazy to verify.
#
system("blobio get --service $service --udig $udig");

cgi2blob(
	extra	=>	<<END
<note>
 Content-Type: $content_type
</note>
END
);
1;
