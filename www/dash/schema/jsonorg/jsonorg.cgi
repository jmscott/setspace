<?xml version="1.0" encoding="UTF-8"?>
<cgi name="jsonorg">
 <title>/cgi-bin/jsonorg</title>
 <synopsis>HTTP CGI Script /cgi-bin/jsonorg</synopsis>
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/jsonorg?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/jsonorg
   </example>
  </examples>
  <out content-type="text/html">

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
    </query-args>
   </putter>

   <putter name="table">
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
    </query-args>
   </putter>

   <putter name="span.nav">
    <query-args>
     <arg
     	name="offset"
	perl5_re="[+0-9]{1,10}"
	default="0"
     />
    </query-args>
   </putter>
  </out>
 </GET>

</cgi>
