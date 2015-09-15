<?xml version="1.0" encoding="UTF-8"?>
<cgi name="is_ascii">
 <title>/cgi-bin/is_ascii</title>
 <synopsis>HTTP CGI Script /cgi-bin/is_ascii</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/is_ascii?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/is_ascii
   </example>
  </examples>
  <out>
   <putter
   	name="a"
	content-type="text/html"
	>
    <query-args>
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
     />
     <arg
     	name="text"
	perl5_re=".{0,255}"
     />
    </query-args>
   </putter>

   <putter
   	name="pre"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
     />
    </query-args>
   </putter>
  </out>
 </GET>
</cgi>
