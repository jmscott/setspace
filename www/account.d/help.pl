#
#  Synopsis:
#	Write <div> help page for script account.
#  Source Path:
#	account.cgi
#  Source SHA1 Digest:
#	No SHA1 Calculated
#  Note:
#	account.d/help.pl was generated automatically by cgi2perl5.
#
#	Do not make changes directly to this script.
#

our (%QUERY_ARG);

print <<END;
<div$QUERY_ARG{id_att}$QUERY_ARG{class_att}>
END
print <<'END';
 <h1>Help Page for <code>/cgi-bin/account</code></h1>
 <div class="overview">
  <h2>Overview</h2>
  <dl>
<dt>Title</dt>
<dd>HTML Form Debugging</dd>
<dt>Synopsis</dt>
<dd>Account Management</dd>
<dt>Blame</dt>
<dd>John the Scott, jmscott@setspace.com</dd>
  </dl>
 </div>
 <div class="GET">
  <h2><code>GET</code> Request.</h2>
   <div class="out">
    <div class="handlers">
    <h3>Output Scripts in <code>$SERVER_ROOT/lib/account.d</code></h3>
    <dl>
     <dt>div.err</dt>
     <dd>
<div class="query-args">
 <h4>Query Args</h4>
 <dl>
  <dt>err</dt>
  <dd>
   <ul>
    <li><code>perl5_re:</code> .{1,255}</li>
   </ul>
  </dd>
  </dl>
</div>
     </dd>
     <dt>logout - Delete Login Cookie</dt>
     <dd>
     </dd>
     <dt>a.ll - Login/Logout Anchor</dt>
     <dd>
     </dd>
  </dl>
 </div>
</div>
 </div>
</div>
END

1;
