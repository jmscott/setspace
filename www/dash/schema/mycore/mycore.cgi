<?xml version="1.0" encoding="UTF-8"?>
<cgi name="mycore">
 <title>/cgi-bin/mycore</title>
 <synopsis>HTTP CGI Script /cgi-bin/mycore</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/mycore?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/mycore
   </example>
  </examples>
  <out>
   <putter name="dl">
    <query-args>
     <arg
     	name="lim"
	perl5_re="[1-9][0-9]{0,3}"
	default="10"
     />
     <arg
     	name="offset"
	perl5_re="[+0-9]{1,10}"
	default="0"
     />
     <arg
     	name="q"
	perl5_re=".{0,255}"
     />
    </query-args>
   </putter>
  </out>
 </GET>
</cgi>
