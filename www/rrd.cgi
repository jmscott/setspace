<?xml version="1.0" encoding="UTF-8"?>
<cgi name="rrd">
 <title>/cgi-bin/rrd</title>
 <synopsis>HTTP CGI Script /cgi-bin/rrd</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/rrd?help"
   >
    Generate a This Help Page for the CGI Script /cgi-bin/rrd
   </example>
  </examples>
  <out>

   <putter
   	content-type="text/html"
   	name="select"
   >
    <query-args>
     <arg
     	name="start"
	perl5_re="[\w]{1,15}"
	default="today"
     >
      <title>start</title>
     </arg>
    </query-args>
   </putter>
  </out>
 </GET>
</cgi>
