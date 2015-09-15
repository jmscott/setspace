#
#  Synopsis:
#	Generate an html <dl> that is a detail of the blob.
#  Note:
#	Null values ought to be indicated with something like
#	<span class="null">&nbsp;</span>
#

require 'account.d/common.pl';
require 'dbi.pl';

our %QUERY_ARG;
my $udig= $QUERY_ARG{udig};

return unless $udig;

my $text_display_length = 2048;

sub put
{
	my %arg = @_;
	my (
		$dt,
		$dd,
		$dd_child,
		$dd_child_ellipse
	) = (
		$arg{dt},
		$arg{dd},
		$arg{dd_child},
		$arg{dd_child_ellipse},
	);

	$dd_child = 'span' unless $dd_child;

	my ($title, $value) = @_;
	print <<END;
 <dt>$dt</dt>
 <dd>
END
	if (defined $dd) {
		$dd = encode_html_entities($dd);
		print <<END;
  <$dd_child>$dd</$dd_child>
END
		#
		#  Tack on ellipse to indicate data was truncated.
		#
		print <<END if $dd_child_ellipse;
  <span class="ellipse">...</span>
END
	} else {
		print <<END;
 <span class="null">&#160;</span>
END
	}
	print <<END;
 </dd>
END
}

my $sql_from;
my $q = dbi_select(
		tag	=>	'blob-dl',
		#dump	=>	'>/tmp/blob-dl.sql',
		db	=>	dbi_connect(),
		sql	=>	<<END
select
	to_char(b.discover_time::timestamp with time zone,
		'YYYY-MM-DD HH24:MI:ss TZ') as "discover_time",
	t.value as "title",
	bc.answer as "byte_count",
	f.readable as "file_readable",
	fm.readable as "file_mime_readable",
	ia.answer as "is_ascii",
	ib.answer as "is_brr_log",
	iu.answer as "is_udig_set",
	i8.answer as "is_utf8wf",
	x.answer as "is_xmlwf",
	pi.readable as "pdfinfo_readable",
	pit.value as "pdfinfo_title",
	pip.value as "pdfinfo_pages",
	substring(p2t.value, 1, $text_display_length) as
				"pdftotext_readable",
	length(p2t.value) > $text_display_length as
			"pdftotext_readable_truncated",
	p2t.text_blob as "pdftotext_readable_blob"
  from
  	blob b
	  left outer join title t on (b.id = t.blob)
	  left outer join byte_count bc on (b.id = bc.blob)
  	  left outer join file f on (b.id = f.blob)
  	  left outer join file_mime fm on (b.id = fm.blob)
  	  left outer join is_ascii ia on (b.id = ia.blob)
  	  left outer join is_brr_log ib on (b.id = ib.blob)
  	  left outer join is_udig_set iu on (b.id = iu.blob)
  	  left outer join is_utf8wf i8 on (b.id = i8.blob)
  	  left outer join is_xmlwf x on (b.id = x.blob)
  	  left outer join pdfinfo pi on (b.id = pi.blob)
  	  left outer join pdfinfo_pages pip on (b.id = pip.blob)
  	  left outer join pdfinfo_title pit on (b.id = pit.blob)
  	  left outer join pdftotext_readable p2t on (b.id = p2t.pdf_blob)
	  $sql_from
  where
	b.id = '$udig'
;
END
);

print <<END;
<dl$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END

my $r;
unless ($r = $q->fetchrow_hashref()) {
	print <<END;
</dl>
END
	return 1;
}

put(
	dt	=>	'Discover Time',
	dd	=>	$r->{discover_time}
);

put(
	dt	=>	'Title',
	dd	=>	$r->{title}
);

put(
	dt	=>	'Size Of in Bytes',
	dd	=>	$r->{byte_count}
);

put(
	dt	=>	'Output of GNU Commandd <code>file</code>',
	dd	=>	$r->{file_readable}
);

put(
	dt	=>	'Output of GNU <code>file --mime-type</code>',
	dd	=>	$r->{file_mime_readable}
);

put(
	dt	=>	'Is Ascii',
	dd	=>	$r->{is_ascii}
);

put(
	dt	=>	'Is BRR Log',
	dd	=>	$r->{is_brr_log}
);

put(
	dt	=>	'Is UDIG Set',
	dd	=>	$r->{is_udig_set}
);

#
#  Shouldn't the utf-8-byte table really be named is-utf-byte.
#
put(
	dt	=>	'Is UTF 8',
	dd	=>	$r->{is_utf8wf}
);

put(
	dt	=>	'Is Well Formed XML - <code>xmlwf</code>',
	dd	=>	$r->{is_xmlwf}
);

put(
	dt		=>	'Output <code>pdfinfo</code> Command',
	dd		=>	$r->{pdfinfo_readable},
	dd_child	=>	'pre'
);

put(
	dt		=>	'Error Output of <code>pdfinfo</code> Command',
	dd		=>	$r->{pdfinfo_error_readable},
	dd_child	=>	'pre'
);

put(
	dt	=>	'Page Count Parsed from <code>pdfinfo</code> Command',
	dd	=>	$r->{pdfinfo_pages},
);

put(
	dt	=>	'Title Parsed from <code>pdfinfo</code> Command',
	dd	=>	$r->{pdfinfo_title},
);

put(
	dt		=>	'Output of <code>pdftotext</code> Command',
	dd		=>	$r->{pdftotext_readable},
	dd_child	=>	'pre',
	dd_child_ellipse=>	$r->{pdftotext_readable_truncated}
);

put(
	dt		=>	'UDIG of <code>pdftotext</code> Readable Text',
	dd		=>	$r->{pdftotext_readable_blob}
);

print <<END;
</dl>
END

1;
