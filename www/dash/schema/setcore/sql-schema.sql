<!DOCTYPE html>
<html>
 <head>
  <title>SetCore Schema</title>
  <meta charset="UTF-8" />
  <link
    href="/screen.css"
    rel="stylesheet"
    type="text/css"
  />
 </head>

 <body>
  <div id="container">
   <!--#include virtual="/header.shtml" -->
   <!--#include virtual="/setcore/nav.shtml" -->
   <div id="content">
    <h2>Core Schema for All Blobs</h2>
    <!--#include virtual=
      "/cgi-bin/setcore?out=dl&class=query&${QUERY_STRING}"
    -->
    <!--#include virtual="/cgi-bin/setcore?out=span.nav&${QUERY_STRING}" -->
   </div>
   <!--#include virtual="/footer.shtml" -->
  </div>
 </body>
</html>
