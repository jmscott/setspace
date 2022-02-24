<?xml version="1.0" encoding="UTF-8"?>
<cgi name="jsonorg">
 <title>/cgi-bin/schema/jsonorg</title>
 <synopsis>HTTP CGI Script /cgi-bin/schema/jsonorg</synopsis>
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/schema/jsonorg?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/schema/jsonorg
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
     	name="q"
	perl5_re=".{0,255}"
     />
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

   <putter name="dl.fail">
   </putter>

   <putter name="span.fail">
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

   <putter name="pre">
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
       name="q"
       perl5_re=".{0,255}"
     />
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

   <putter
     name="mime.json"
     content-type="application/json"
   >
    <query-args>
     <arg
     	name="udig"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter
     name="select.topk"
     content-type="text/html"
   >
    <query-args>
     <arg
     	name="topk"
	perl5_re=".*"
	required="no"
     />
    </query-args>
   </putter>

  </out>
 </GET>

</cgi>
