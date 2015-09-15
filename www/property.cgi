<?xml version="1.0" encoding="UTF-8"?>
<cgi name="property">
 <title>/cgi-bin/property</title>
 <synopsis>HTTP CGI Script /cgi-bin/property</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/property?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/property
   </example>
  </examples>
  <out>
   <putter
   	name="table"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="start"
	perl5_re="[\w]{1,15}"
	default="today"
     />
    </query-args>
   </putter>
  </out>
 </GET>
</cgi>
