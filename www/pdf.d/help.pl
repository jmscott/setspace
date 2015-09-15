#
#  Synopsis:
#	Write <div> help page for script pdf.
#  Source Path:
#	pdf.cgi
#  Source SHA1 Digest:
#	No SHA1 Calculated
#  Note:
#	pdf.d/help.pl was generated automatically by cgi2perl5.
#
#	Do not make changes directly to this script.
#

our (%QUERY_ARG);

print <<END;
<div$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END
print <<'END';
 <h1>Help Page for <code>/cgi-bin/pdf</code></h1>
 <div class="overview">
  <h2>Overview</h2>
  <dl>
<dt>Title</dt>
<dd>/cgi-bin/pdf</dd>
<dt>Synopsis</dt>
<dd>HTTP CGI Script /cgi-bin/pdf</dd>
<dt>Blame</dt>
<dd>jmscott</dd>
  </dl>
 </div>
 <div class="GET">
  <h2><code>GET</code> Request.</h2>
   <div class="out">
    <div class="handlers">
    <h3>Output Scripts in <code>$SERVER_ROOT/lib/pdf.d</code></h3>
    <dl>
     <dt>input</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>q</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> .{0,255}</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>select.oby</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>oby</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> tscd|dtimd|dtima|pgcoa|pgcod|rand</li>
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
    <li><code>perl5_re:</code> 10|20|100|1000|10000</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>dl</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>q</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> .{0,255}</li>
   </ul>
  </dd>
  <dt>rppg</dt>
  <dd>
   <ul>
    <li><code>default:</code> 10</li>
    <li><code>perl5_re:</code> \d{1,10}</li>
   </ul>
  </dd>
  <dt>page</dt>
  <dd>
   <ul>
    <li><code>default:</code> 1</li>
    <li><code>perl5_re:</code> [1-9]\d{0,9}</li>
   </ul>
  </dd>
  <dt>oby</dt>
  <dd>
   <ul>
    <li><code>default:</code> tscd</li>
    <li><code>perl5_re:</code> tscd|dtimd|dtima|pgcoa|pgcod|rand</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>blob</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>udig</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [^:]{1,15}:[^:]{1,255}</li>
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
  <dt>q</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> .{0,255}</li>
   </ul>
  </dd>
  <dt>rppg</dt>
  <dd>
   <ul>
    <li><code>default:</code> 10</li>
    <li><code>perl5_re:</code> \d{1,10}</li>
   </ul>
  </dd>
  <dt>page</dt>
  <dd>
   <ul>
    <li><code>default:</code> 1</li>
    <li><code>perl5_re:</code> [1-9]\d{0,9}</li>
   </ul>
  </dd>
  <dt>oby</dt>
  <dd>
   <ul>
    <li><code>default:</code> tscd</li>
    <li><code>perl5_re:</code> tscd|dtimd|dtima|pgcoa|pgcod|rand</li>
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
   <dt><a href="/cgi-bin/pdf?/cgi-bin/pdf?help">/cgi-bin/pdf?/cgi-bin/pdf?help</a></dt>
   <dd>Generate a This Help Page for the CGI Script /cgi-bin/pdf</dd>
 </dl>
</div>
 </div>
</div>
END

1;
