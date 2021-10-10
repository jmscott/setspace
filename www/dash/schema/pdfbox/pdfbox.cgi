<?xml version="1.0" encoding="UTF-8"?>

<cgi name="pdfbox">
 <title>/cgi-bin/schema/pdfbox</title>
 <synopsis>HTTP CGI Script /cgi-bin/schema/pdfbox</synopsis>
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/schema/pdfbox?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/schema/pdfbox
   </example>
  </examples>
  <out>
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
     	name="limit"
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
     name="dl"
     content-type="text/html"
   >
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
     	name="limit"
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
     name="span.nav"
     content-type="text/html"
   >
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
     	name="limit"
	perl5_re="[1-9][0-9]{0,3}"
	default="10"
     />
    </query-args>
   </putter>

   <putter
     name="input"
     content-type="text/html"
   > 
    <query-args>
     <arg
     	name="q"
	perl5_re=".{0,255}"
     />
    </query-args>
   </putter>

   <putter
     name="input.mytitle"
     content-type="text/html"
   > 
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
     />
     <arg
     	name="title"
	perl5_re=".*{1,255}"
     />
    </query-args>
   </putter>

   <putter name="mime.pdf">
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter
     name="a.mime"
     content-type="text/html"
   >
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter
     name="iframe.pdf"
     content-type="text/html"
   >
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter
     name="utf8.pg1"
     content-type="text/html"
   >
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
     <arg
     	name="len"
	perl5_re="\d{1,10}"
	default="65535"
     />
    </query-args>
   </putter>

   <putter
     name="dl.pddoc"
     content-type="text/html"
   >
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter
     name="dl.pdinfo"
     content-type="text/html"
   >
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter
     name="dl.extpg"
     content-type="text/html"
   >
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter
     name="table.exttsv"
     content-type="text/html"
   > 
    <query-args>
     <arg
     	name="blob"
	perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
	required="yes"
     />
    </query-args>
   </putter>

   <putter
     name="text.objdesc"
     content-type="text/html"
   >
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
    </vars>
   </putter>

   <putter name="post.mytitle">
    <title>Update PDF tite in mycore.title</title>
    <vars>
     <var
       name="blob"
       perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
     />
     <var
       name="title"
       perl5_re=".{1,255}"
     />
    </vars>
   </putter>
  </in>
 </POST>
</cgi>
