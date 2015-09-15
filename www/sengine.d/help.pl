#
#  Synopsis:
#	Write <div> help page for script sengine.
#  Source Path:
#	sengine.cgi
#  Source SHA1 Digest:
#	No SHA1 Calculated
#  Note:
#	sengine.d/help.pl was generated automatically by cgi2perl5.
#
#	Do not make changes directly to this script.
#

our (%QUERY_ARG);

print <<END;
<div$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END
print <<'END';
 <h1>Help Page for <code>/cgi-bin/sengine</code></h1>
 <div class="overview">
  <h2>Overview</h2>
  <dl>
<dt>Title</dt>
<dd>/cgi-bin/sengine</dd>
<dt>Synopsis</dt>
<dd>HTTP CGI Script /cgi-bin/sengine</dd>
<dt>Blame</dt>
<dd>jmscott</dd>
  </dl>
 </div>
 <div class="GET">
  <h2><code>GET</code> Request.</h2>
   <div class="out">
    <div class="handlers">
    <h3>Output Scripts in <code>$SERVER_ROOT/lib/sengine.d</code></h3>
    <dl>
     <dt>select</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>q</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> .{1,255}</li>
   </ul>
  </dd>
  <dt>eng</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> \w{1,32}</li>
   </ul>
  </dd>
  <dt>page</dt>
  <dd>
   <ul>
    <li><code>default:</code> setspace</li>
    <li><code>perl5_re:</code> \w{1,32}</li>
   </ul>
  </dd>
  <dt>rppg</dt>
  <dd>
   <ul>
    <li><code>default:</code> 20</li>
    <li><code>perl5_re:</code> 10|20|100|1000|10000</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>input</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>q</dt>
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
   <dt><a href="/cgi-bin/sengine?/cgi-bin/sengine?help">/cgi-bin/sengine?/cgi-bin/sengine?help</a></dt>
   <dd>Generate This Help Page for the CGI Script /cgi-bin/sengine</dd>
 </dl>
</div>
 </div>
</div>
END

1;
