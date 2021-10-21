#
#  Synopsis:
#	Write <div> help page for script stats.
#  Source Path:
#	stats.cgi
#  Source SHA1 Digest:
#	No SHA1 Calculated
#  Note:
#	stats.d/help.pl was generated automatically by cgi2perl5.
#
#	Do not make changes directly to this script.
#

our (%QUERY_ARG);

print <<END;
<div$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END
print <<'END';
 <h1>Help Page for <code>/cgi-bin/schema/stats</code></h1>
 <div class="overview">
  <h2>Overview</h2>
  <dl>
<dt>Title</dt>
<dd>/cgi-bin/schema/stats</dd>
<dt>Synopsis</dt>
<dd>HTTP CGI Script /cgi-bin/schema/stats</dd>
<dt>Blame</dt>
<dd>jmscott</dd>
  </dl>
 </div>
 <div class="GET">
  <h2><code>GET</code> Request.</h2>
   <div class="out">
    <div class="handlers">
    <h3>Output Scripts in <code>$SERVER_ROOT/lib/schema/stats.d</code></h3>
    <dl>
     <dt>table</dt>
     <dd>
     </dd>
  </dl>
 </div>
</div>
<div class="examples">
 <h3>Examples</h3>
 <dl>
   <dt><a href="/cgi-bin/schema/stats?/cgi-bin/schema/stats?help">
stats?/cgi-bin/schema/stats?help</a></dt>
   <dd>Generate This Help Page for the CGI Script /cgi-bin/schema</dd>
 </dl>
</div>
 </div>
</div>
END

1;
