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
     	name="offset"
	perl5_re="[+0-9]{1,10}"
	default="0"
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
     	name="offset"
	perl5_re="[+0-9]{1,10}"
	default="0"
     />
     <arg
     	name="qtype"
	perl5_re="web|key|phrase|fts"
	default="web"
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
     	name="offset"
	perl5_re="[+0-9]{1,10}"
	default="0"
     />
     <arg
     	name="qtype"
	perl5_re="web|key|phrase|fts"
	default="web"
     />
    </query-args>
   </putter>

   <putter name="select.qtype">
    <query-args>
     <arg
     	name="qtype"
	perl5_re="web|key|phrase|fts"
	default="web"
     />
    </query-args>
   </putter>

   <putter name="input">
    <query-args>
     <arg
     	name="q"
	perl5_re=".{0,255}"
     />
    </query-args>
   </putter>

   <putter
     name="mime.pdf"
     content-type="application/pdf"
   >
    <query-args>
     <arg
     	name="udig"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter name="dl.pddoc">
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter name="dl.pdinfo">
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter name="dl.extpg">
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter name="text.objdesc">
    <query-args>
     <arg
     	name="name"
	perl5_re="^[a-z][a-z0-9_]{0,64}"
	required="yes"
     />
    </query-args>
   </putter>

  </out>
 </GET>

 <POST>
  <in>
   <putter name="post.q">
    <title>POST a search query</title>
    <vars>
     <var
       name="q"
       perl5_re=".{0,255}"
     />
     <var
       name="qtype"
       perl5_re="web|key|phrase|fts"
     />
    </vars>
   </putter>
  </in>
 </POST>
</cgi>
