<?xml version="1.0" encoding="UTF-8"?>
<cgi name="fffile5">
 <title>/cgi-bin/schema/fffile5</title>
 <synopsis>HTTP CGI Script /cgi-bin/schema/fffile5</synopsis>
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/schema/fffile5?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/schema/fffile5
   </example>
  </examples>
  <out>

   <putter
     name="select.mt"
     content-type="text/html"
   >
    <query-args>
     <arg
       name="mt"
       perl5_re=".*"
       required="no"
     />
    </query-args>
   </putter>

   <putter name="mime.mt">
    <query-args>
     <arg
       name="blob"
       perl5_re="[a-z][a-z0-9]{0,7}:[[:graph:]]{32,128}"
       required="yes"
     />
    </query-args>
   </putter>

   <putter
     name="dl.mt"
     content-type="text/html"
   >
    <query-args>
     <arg
       name="mt"
       perl5_re="[[:graph:]]{1,64}"
       required="no"
     />
    </query-args>
   </putter>
  </out>
 </GET>
 <POST>
  <in>
   <putter name="post.mt">
    <title>POST a search for blobs by mime type</title>
    <vars>
     <var
       name="mt"
       perl5_re=".*"
       required="yes"
     />
    </vars>
   </putter>
  </in>
 </POST>

</cgi>
