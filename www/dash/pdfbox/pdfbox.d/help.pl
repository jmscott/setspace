#
#  Synopsis:
#	Write <div> help page for script pdfbox.
#  Source Path:
#	pdfbox.cgi
#  Source SHA1 Digest:
#	No SHA1 Calculated
#  Note:
#	pdfbox.d/help.pl was generated automatically by cgi2perl5.
#
#	Do not make changes directly to this script.
#

our (%QUERY_ARG);

print <<END;
<div$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END
print <<'END';
 <h1>Help Page for <code>/cgi-bin/pdfbox</code></h1>
 <div class="overview">
  <h2>Overview</h2>
  <dl>
<dt>Title</dt>
<dd>/cgi-bin/pdfbox</dd>
<dt>Synopsis</dt>
<dd>HTTP CGI Script /cgi-bin/pdfbox</dd>
<dt>Blame</dt>
<dd>jmscott</dd>
  </dl>
 </div>
 <div class="GET">
  <h2><code>GET</code> Request.</h2>
   <div class="out">
    <div class="handlers">
    <h3>Output Scripts in <code>$SERVER_ROOT/lib/pdfbox.d</code></h3>
    <dl>
     <dt>table</dt>
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
  <dt>tsconf</dt>
  <dd>
   <ul>
    <li><code>default:</code> english</li>
    <li><code>perl5_re:</code> [a-z0-9-]{1,32}</li>
   </ul>
  </dd>
  <dt>rnorm</dt>
  <dd>
   <ul>
    <li><code>default:</code> 14</li>
    <li><code>perl5_re:</code> [0-9]{1,3}</li>
   </ul>
  </dd>
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
  <dt>tsconf</dt>
  <dd>
   <ul>
    <li><code>default:</code> english</li>
    <li><code>perl5_re:</code> [a-z0-9-]{1,32}</li>
   </ul>
  </dd>
  <dt>rnorm</dt>
  <dd>
   <ul>
    <li><code>default:</code> 14</li>
    <li><code>perl5_re:</code> [0-9]{1,3}</li>
   </ul>
  </dd>
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
  <dt>qtype</dt>
  <dd>
   <ul>
    <li><code>default:</code> web</li>
    <li><code>perl5_re:</code> web|key|phrase|fts</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>span.nav</dt>
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
  <dt>offset</dt>
  <dd>
   <ul>
    <li><code>default:</code> 0</li>
    <li><code>perl5_re:</code> [+0-9]{1,10}</li>
   </ul>
  </dd>
  <dt>qtype</dt>
  <dd>
   <ul>
    <li><code>default:</code> web</li>
    <li><code>perl5_re:</code> web|key|phrase|fts</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>select.qtype</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>qtype</dt>
  <dd>
   <ul>
    <li><code>default:</code> web</li>
    <li><code>perl5_re:</code> web|key|phrase|fts</li>
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
    <li><code>perl5_re:</code> .{0,255}</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>mime.pdf</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>udig</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}</li>
    <li><code>required:</code> yes</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>dl.pddoc</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>blob</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}</li>
    <li><code>required:</code> yes</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>dl.pdinfo</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>blob</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}</li>
    <li><code>required:</code> yes</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>dl.extpg</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>blob</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}</li>
    <li><code>required:</code> yes</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>table.exttsv</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>blob</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> [a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}</li>
    <li><code>required:</code> yes</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>text.objdesc</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>name</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> ^[a-z][a-z0-9_]{0,64}</li>
    <li><code>required:</code> yes</li>
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
   <dt><a href="/cgi-bin/pdfbox?/cgi-bin/pdfbox?help">/cgi-bin/pdfbox?/cgi-bin/pdfbox?help</a></dt>
   <dd>Generate This Help Page for the CGI Script /cgi-bin/pdfbox</dd>
 </dl>
</div>
 </div>
</div>
END

1;