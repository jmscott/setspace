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
  <out content-type="text/html">

   <putter name="select.mt">
    <query-args>
     <arg
       name="mt"
       perl5_re=".*"
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
