#
#  Synopsis:
#	Write html <a> link to /blob-ascii.shtml for existing ascii udig
#
require 'dbi.pl';

our %QUERY_ARG;

my $udig = $QUERY_ARG{udig};

return 1 unless $udig;

my $q = dbi_select(
	db	=>	dbi_connect(),
	tag	=>	'is_ascii-a',
	#dump	=>	'>/tmp/is_ascii-a.sql',
	sql	=>	<<END
select
	a.blob
  from
  	is_ascii a
  where
  	a.blob = '$udig'
	and
	a.answer is true
;
END
);

my $r = $q->fetchrow_hashref();
return 1 unless $r;

my $text = encode_html_entities($QUERY_ARG{text} ? $QUERY_ARG{text} : $udig);

print <<END;
<a$QUERY_ARG{id_att}$QUERY_ARG{class_att}
	title="$udig"
	href="/blob-ascii.shtml?udig=$udig"
>$text</a>
END

1;
