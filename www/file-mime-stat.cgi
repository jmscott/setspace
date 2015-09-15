<?xml version="1.0" encoding="UTF-8"?>
<cgi name="file-mime-stat">
 <title>/cgi-bin/file-mime-stat</title>
 <synopsis>HTTP CGI Script /cgi-bin/file-mime-stat</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/file-mime-stat?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/file-mime-stat
   </example>
  </examples>
  <out>
   <putter
   	name="select"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="mime"
	perl5_re=".{1,255}"
     />
    </query-args>
   </putter>
  </out>
 </GET>
</cgi>
