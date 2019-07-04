#
#  Synopsis:
#	Write <div> help page for script tag-url.
#  Source Path:
#	tag-url.cgi
#  Source SHA1 Digest:
#	No SHA1 Calculated
#  Note:
#	tag-url.d/help.pl was generated automatically by cgi2perl5.
#
#	Do not make changes directly to this script.
#

our (%QUERY_ARG);

print <<END;
<div$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END
print <<'END';
 <h1>Help Page for <code>/cgi-bin/tag-url</code></h1>
 <div class="overview">
  <h2>Overview</h2>
  <dl>
<dt>Title</dt>
<dd>/cgi-bin/tag-url</dd>
<dt>Synopsis</dt>
<dd>HTTP CGI Script /cgi-bin/tag-url</dd>
<dt>Blame</dt>
<dd>jmscott</dd>
  </dl>
 </div>
 <div class="GET">
  <h2><code>GET</code> Request.</h2>
   <div class="out">
    <div class="handlers">
    <h3>Output Scripts in <code>$SERVER_ROOT/lib/tag-url.d</code></h3>
    <dl>
     <dt>a</dt>
     <dd>
     </dd>
     <dt>textarea</dt>
     <dd>
     </dd>
     <dt>dl</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>rppg</dt>
  <dd>
   <ul>
    <li><code>default:</code> 10</li>
    <li><code>perl5_re:</code> 10|100|1000|10000</li>
   </ul>
  </dd>
  <dt>page</dt>
  <dd>
   <ul>
    <li><code>default:</code> 1</li>
    <li><code>perl5_re:</code> [1-9]\d{0,9}</li>
   </ul>
  </dd>
  <dt>host</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [\w.-]{1,255}</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>select.rppg</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>rppg</dt>
  <dd>
   <ul>
    <li><code>default:</code> 10</li>
    <li><code>perl5_re:</code> 10|100|1000|10000</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>div.nav</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>rppg</dt>
  <dd>
   <ul>
    <li><code>default:</code> 10</li>
    <li><code>perl5_re:</code> 10|100|1000|10000</li>
   </ul>
  </dd>
  <dt>page</dt>
  <dd>
   <ul>
    <li><code>default:</code> 1</li>
    <li><code>perl5_re:</code> [1-9]\d{0,9}</li>
   </ul>
  </dd>
  <dt>host</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [\w.-]{1,255}</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>save</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>url</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> .{0,255}</li>
    <li><code>required:</code> yes</li>
   </ul>
  </dd>
  <dt>title</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> .{0,255}</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>click</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>udig</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [a-z][a-z0-9]{0,14}:[[:graph:]]{1,255}</li>
    <li><code>required:</code> yes</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>div.err</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>err</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [[:print:]]{1,255}</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>select.host</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>host</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [\w.-]{1,255}</li>
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
   <dt><a href="/cgi-bin/tag-url?/cgi-bin/tag-url?help">/cgi-bin/tag-url?/cgi-bin/tag-url?help</a></dt>
   <dd>Generate This Help Page for the CGI Script /cgi-bin/tag-url</dd>
 </dl>
</div>
 </div>
</div>
END

1;
