<?xml version="1.0" encoding="UTF-8"?>
<cgi name="my">
 <title>/cgi-bin/my</title>
 <synopsis>HTTP CGI Script /cgi-bin/my</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/my?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/my
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
   	name="form"
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

 <POST>
  <in>
   <putter name="save">
    <vars>
     <var
     	name="udig"
	perl5_re="[[:alnum:]]{1,15}:[[:graph:]]{1,255}"
	required="yes"
     />
     <var
     	name="blob-title"
	perl5_re=".{1,255}"
     />
    </vars>
   </putter>
  </in>
 </POST>
</cgi>
