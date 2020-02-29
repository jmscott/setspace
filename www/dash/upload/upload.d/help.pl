#
#  Synopsis:
#	Write <div> help page for script upload.
#  Source Path:
#	upload.cgi
#  Source SHA1 Digest:
#	No SHA1 Calculated
#  Note:
#	upload.d/help.pl was generated automatically by cgi2perl5.
#
#	Do not make changes directly to this script.
#

our (%QUERY_ARG);

print <<END;
<div$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END
print <<'END';
 <h1>Help Page for <code>/cgi-bin/upload</code></h1>
 <div class="overview">
  <h2>Overview</h2>
  <dl>
<dt>Title</dt>
<dd>/cgi-bin/upload</dd>
<dt>Synopsis</dt>
<dd>HTTP CGI Script /cgi-bin/upload</dd>
<dt>Blame</dt>
<dd>jmscott</dd>
  </dl>
 </div>
</div>
END

1;
