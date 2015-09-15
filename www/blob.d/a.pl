#
#  Synopsis:
#	Write html <a> link to blob if udig query exists.
#

our %QUERY_ARG;

my $udig = $QUERY_ARG{udig};

return unless $udig;

my $text = encode_html_entities($QUERY_ARG{text} ? $QUERY_ARG{text} : $udig);

print <<END;
<a$QUERY_ARG{id_att}$QUERY_ARG{class_att}
	title="$udig"
	href="/cgi-bin/blob?out=mime&amp;udig=$udig"
>$text</a>
END

1;
