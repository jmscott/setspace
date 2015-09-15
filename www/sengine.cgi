<?xml version="1.0" encoding="UTF-8"?>
<cgi name="sengine">
 <title>/cgi-bin/sengine</title>
 <synopsis>HTTP CGI Script /cgi-bin/sengine</synopsis>
 <subversion id="$Id$" />
 <blame>jmscott</blame>
 <GET>
  <examples>
   <example
   	query="/cgi-bin/sengine?help"
   >
    Generate This Help Page for the CGI Script /cgi-bin/sengine
   </example>
  </examples>
  <out>

   <putter
   	name="select"
	content-type="text/html"
	>
    <!--
	 What are these query arguments ???
    -->
    <query-args>
     <arg
     	name="q"
	perl5_re=".{1,255}"
     />
     <arg
     	name="eng"
	perl5_re="\w{1,32}"
     />
     <arg
     	name="page"
	perl5_re="\w{1,32}"
	default="setspace"
     />
     <arg
     	name="rppg"
	perl5_re="10|20|100|1000|10000"
	default="20"
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
	perl5_re=".{1,255}"
     />
    </query-args>

   </putter>

  </out>
 </GET>

 <POST>
  <in>
   <putter name="rd">
    <vars>
     <var
     	name="q"
	perl5_re=".{1,255}"
     />
     <var
     	name="eng"
	perl5_re="\w{1,32}"
     />
     <var
     	name="rppg"
	perl5_re="10|20|100|1000|10000"
     />
     <var
     	name="page"
	perl5_re="\d{1,10}"
     />
     <var
     	name="oby"
	perl5_re="tscd|dtimd|dtima|pgcoa|pgcod|rand"
     />
    </vars>
   </putter>
  </in>
 </POST>
</cgi>
