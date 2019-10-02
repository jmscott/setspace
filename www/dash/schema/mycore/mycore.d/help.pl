#
#  Synopsis:
#	Write <div> help page for script mycore.
#  Source Path:
#	mycore.cgi
#  Note:
#	mycore.d/help.pl was generated automatically by cgi2perl5.
#
#	Do not make changes directly to this script.
#

our (%QUERY_ARG);

print <<END;
<div$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END
print <<'END';
 <h1>Help Page for <code>/cgi-bin/mycore</code></h1>
 <div class="overview">
  <h2>Overview</h2>
  <dl>
<dt>Title</dt>
<dd>/cgi-bin/mycore</dd>
<dt>Synopsis</dt>
<dd>HTTP CGI Script /cgi-bin/mycore</dd>
<dt>Blame</dt>
<dd>jmscott</dd>
  </dl>
 </div>
 <div class="GET">
  <h2><code>GET</code> Request.</h2>
   <div class="out">
    <div class="handlers">
    <h3>Output Scripts in <code>$SERVER_ROOT/lib/mycore.d</code></h3>
    <dl>
     <dt>dl</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>lim</dt>
  <dd>
   <ul>
    <li><code>default:</code> 10</li>
    <li><code>perl5_re:</code> [1-9][0-9]{0,3}</li>
   </ul>
  </dd>
  <dt>offset</dt>
  <dd>
   <ul>
    <li><code>default:</code> 0</li>
    <li><code>perl5_re:</code> [+0-9]{1,10}</li>
   </ul>
  </dd>
  <dt>q</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> .{0,255}</li>
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
   <dt><a href="/cgi-bin/jmscott/mycore?/cgi-bin/mycore?help">/cgi-bin/jmscott/mycore?/cgi-bin/mycore?help</a></dt>
   <dd>Generate This Help Page for the CGI Script /cgi-bin/mycore</dd>
 </dl>
</div>
 </div>
</div>
END

1;
