<?xml version="1.0" encoding="UTF-8"?>
<cgi name="pdfbox">
 <title>/cgi-bin/pdfbox</title>
 <synopsis>HTTP CGI Script /cgi-bin/pdfbox</synopsis>
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/pdfbox?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/pdfbox
   </example>
  </examples>
  <out content-type="text/html">
   <putter name="table">
    <query-args>
     <arg
     	name="q"
	perl5_re=".{0,255}"
     />
     <arg
     	name="tsconf"
	perl5_re="[a-z0-9-]{1,32}"
	default="english"
     />
     <arg
     	name="rnorm"
	perl5_re="[0-9]{1,3}"
	default="14"
     />
     <arg
     	name="lim"
	perl5_re="[1-9][0-9]{0,3}"
	default="10"
     />
     <arg
     	name="off"
	perl5_re="[1-9][0-9]{0,9}"
	default="1"
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
     	name="tsconf"
	perl5_re="[a-z0-9-]{1,32}"
	default="english"
     />
     <arg
     	name="rnorm"
	perl5_re="[0-9]{1,3}"
	default="14"
     />
     <arg
     	name="lim"
	perl5_re="[1-9][0-9]{0,3}"
	default="10"
     />
     <arg
     	name="off"
	perl5_re="[1-9][0-9]{0,9}"
	default="1"
     />
    </query-args>
   </putter>

   <putter name="input.q">
    <query-args>
     <arg
     	name="q"
	perl5_re=".{0,255}"
     />
    </query-args>
   </putter>
  </out>
 </GET>
</cgi>
