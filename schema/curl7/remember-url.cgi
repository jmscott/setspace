<?xml version="1.0" encoding="UTF-8"?>
<cgi name="remember-url">
 <title>/cgi-bin/remember-url</title>
 <synopsis>HTTP CGI Script /cgi-bin/remember-url</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/remember-url?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/remember-url
   </example>
  </examples>
  <out>
   <putter
   	name="a"
	content-type="text/html"
   />
   <putter
   	name="textarea"
	content-type="text/html"
   />

   <putter
   	name="dl"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="rppg"
	perl5_re="10|100|1000|10000"
	default="10"
     />
     <arg
    	name="page"
	default="1"
	perl5_re="[1-9]\d{0,9}"
     />
     <arg
     	name="host"
	perl5_re="[\w.-]{1,255}"
     />
    </query-args>
   </putter>

   <putter
   	name="select.rppg"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="rppg"
	perl5_re="10|100|1000|10000"
	default="10"
     />
    </query-args>
   </putter>

   <putter
   	name="div.nav"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="rppg"
	perl5_re="10|100|1000|10000"
	default="10"
     />
     <arg
    	name="page"
	default="1"
	perl5_re="[1-9]\d{0,9}"
     />
     <arg
     	name="host"
	perl5_re="[\w.-]{1,255}"
     />
    </query-args>
   </putter>

   <putter name="save">
    <query-args>
     <arg
     	name="url"
	perl5_re=".{0,255}"
	required="yes"
     />
     <arg
     	name="title"
	perl5_re=".{0,255}"
     />
    </query-args>
   </putter>

   <putter name="click">
    <query-args>
     <arg
      name="udig"
      perl5_re="[a-z][a-z0-9]{0,14}:[[:graph:]]{1,255}"
      required="yes"
     />
    </query-args>
   </putter>

   <putter
   	name="div.err"
	content-type="text/html"
	>
    <query-args>
     <arg
     	name="err"
	perl5_re="[[:print:]]{1,255}"
     />
    </query-args>
   </putter>

   <putter
   	name="select.host"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="host"
	perl5_re="[\w.-]{1,255}"
     />
    </query-args>
   </putter>

  </out>
 </GET>
</cgi>
