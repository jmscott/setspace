#
#  Synopsis:
#	Write http <textarea> of javascript code to tag a url.
#

our %QUERY_ARG;

print <<END;
<textarea$QUERY_ARG{class_att}$QUERY_ARG{id_att}>
javascript:location.href=&apos;https://$ENV{HTTP_HOST}/cgi-bin/tag-url?out=save&amp;url=&apos;+encodeURIComponent(location.href)+&apos;&amp;title=&apos;+encodeURIComponent(document.title);
</textarea>
END

1;
