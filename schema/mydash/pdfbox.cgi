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
    </query-args>
   </putter>
  </out>
 </GET>
</cgi>
