#
#  Synopsis:
#	Write http <a> of bookmarklet
#

our %QUERY_ARG;

print <<END;
<textarea$QUERY_ARG{class_att}$QUERY_ARG{id_att}>
javascript:location.href=&apos;http://$ENV{HTTP_HOST}/cgi-bin/remember-uri?out=save&amp;uri=&apos;+encodeURIComponent(location.href)+&apos;&amp;title=&apos;+encodeURIComponent(document.title);
</textarea>
END

1;
