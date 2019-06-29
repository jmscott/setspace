#
#  Synopsis:
#	Write http <a> of bookmarklet
#

our %QUERY_ARG;

print <<END;
<a$QUERY_ARG{class_att}$QUERY_ARG{id_att}
href="javascript:document.location.href='http://$ENV{HTTP_HOST}/cgi-bin/remember-url?out=save&amp;url='+encodeURIComponent(location.href)+'&amp;title='+encodeURIComponent(document.title);"
>Remember</a>
END

1;
