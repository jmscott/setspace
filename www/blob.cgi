<?xml version="1.0" encoding="UTF-8"?>
<cgi name="blob">
 <title>/cgi-bin/blob</title>
 <synopsis>HTTP CGI Script /cgi-bin/blob</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/blob?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/blob
   </example>
  </examples>

  <out>
   <putter
   	name="input"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
     />
    </query-args>
   </putter>

   <putter
   	name="title"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
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
	default="20"
	perl5_re="\d{1,10}"
     />
     <arg
    	name="page"
	default="1"
	perl5_re="[1-9]\d{0,9}"
     />
     <arg
    	name="mime"
	perl5_re=".{0,255}"
     />
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
     />
    </query-args>
   </putter>

   <putter
   	name="dl"
	content-type="text/html"
   >
    <query-args>
     <arg
    	name="rppg"
	default="20"
	perl5_re="\d{1,10}"
     />
     <arg
    	name="page"
	default="1"
	perl5_re="[1-9]\d{0,9}"
     />
     <arg
     	name="oby"
	perl5_re="rand|dtime|adtim|bcnta|bcntd"
	default="dtime"
     />
     <arg
     	name="mime"
	perl5_re=".{0,255}"
     />
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
     />
    </query-args>
   </putter>

   <putter
   	name="select.oby"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="oby"
	perl5_re="rand|dtime|adtim|bcnta|bcntd"
	default="dtime"
     />
    </query-args>
   </putter>

   <putter
   	name="pre.hex"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
     />
    </query-args>
   </putter>

   <putter
   	name="pre.hex"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
     />
    </query-args>
   </putter>

   <putter
   	name="dl.detail"
	content-type="text/html"
   >
    <query-args>
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
     />
    </query-args>

   </putter>

   <putter
   	name="mime"
   >
    <query-args>
     <arg
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
     />
    </query-args>
   </putter>

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
   	name="a.hex"
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

  </out>
 </GET>
</cgi>
