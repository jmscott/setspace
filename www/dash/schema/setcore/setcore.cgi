<?xml version="1.0" encoding="UTF-8"?>
<cgi name="setcore">
 <title>/cgi-bin/schema/setcore</title>
 <synopsis>HTTP CGI Script /cgi-bin/schema/setcore</synopsis>
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/schema/setcore
   </example>
  </examples>
  <out content-type="text/html">

   <putter name="input">
    <query-args>
     <arg
     	name="q"
	perl5_re=".{0,255}"
     />
    </query-args>
   </putter>

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

   <putter name="pre.hex">
    <query-args>
     <arg
       name="blob"
       perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
       required="yes"
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
     <arg
     	name="q"
	perl5_re=".{0,255}"
     />
    </query-args>
   </putter>
  </out>
 </GET>

</cgi>
