<?xml version="1.0" encoding="UTF-8"?>
<cgi name="stats">
 <title>/cgi-bin/schema/stats</title>
 <synopsis>HTTP CGI Script /cgi-bin/schema/stats</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/schema/stats?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/schema
   </example>
  </examples>
  <out content-type="text/html">
   <putter name="table"></putter>
   <putter name="table.sch">
    <query-args>
     <arg
     	name="sch"
	perl5_re="[a-z][a-z0-9]{0,15}"
	required="yes"
     />
     
    </query-args>
   </putter>
  </out>
 </GET>
</cgi>
