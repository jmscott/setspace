#
#  Synopsis:
#	Write <div> help page for script file-mime-stat.
#  Source Path:
#	file-mime-stat.cgi
#  Source SHA1 Digest:
#	No SHA1 Calculated
#  Note:
#	file-mime-stat.d/help.pl was generated automatically by cgi2perl5.
#
#	Do not make changes directly to this script.
#

our (%QUERY_ARG);

print <<END;
<div$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END
print <<'END';
 <h1>Help Page for <code>/cgi-bin/file-mime-stat</code></h1>
 <div class="overview">
  <h2>Overview</h2>
  <dl>
<dt>Title</dt>
<dd>/cgi-bin/file-mime-stat</dd>
<dt>Synopsis</dt>
<dd>HTTP CGI Script /cgi-bin/file-mime-stat</dd>
<dt>Blame</dt>
<dd>jmscott</dd>
  </dl>
 </div>
 <div class="GET">
  <h2><code>GET</code> Request.</h2>
   <div class="out">
    <div class="handlers">
    <h3>Output Scripts in <code>$SERVER_ROOT/lib/file-mime-stat.d</code></h3>
    <dl>
     <dt>select</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>mime</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> .{1,255}</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
  </dl>
 </div>
</div>
<div class="examples">
 <h3>Examples</h3>
 <dl>
   <dt><a href="/cgi-bin/file-mime-stat?/cgi-bin/file-mime-stat?help">/cgi-bin/file-mime-stat?/cgi-bin/file-mime-stat?help</a></dt>
   <dd>Generate This Help Page for the CGI Script /cgi-bin/file-mime-stat</dd>
 </dl>
</div>
 </div>
</div>
END

1;
