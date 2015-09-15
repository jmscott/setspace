<?xml version="1.0" encoding="UTF-8"?>
<cgi
	name="account"
 >
 <title>HTML Form Debugging</title>
 <synopsis>
 Account Management
 </synopsis>
 <subversion
 	id="$Id"
 />
 <blame>John the Scott, jmscott@setspace.com</blame>
 <GET>
  <out>
   <putter
   	name="div.err"
	content-type="text/html"
	>
    <query-args>
     <arg
     	name="err"
	perl5_re=".{1,255}"
     />
    </query-args>
   </putter>

   <putter
 	name="logout" >
    <title>Delete Login Cookie</title>
   </putter>

  <putter
  	content-type="text/html"
 	name="a.ll">
   <title>Login/Logout Anchor</title>
  </putter>
  </out>
 </GET>

<POST>
 <in>
  <putter
 	name="post.dump" >
  <title>Dump an HTTP POST Request</title>
  <synopsis>Write a &lt;div&gt; element that contains the process
  environment and the parsed posted data.  Helpful when debuging
  an existing form.  Just add or modify
  the following attributes to your &lt;form&gt; element

  	&lt;form action=&quot;env&quot; name=&quot;div.dump&quot;.
  Be sure that the attribute method=&quot;POST&quot; is set
  or your browser will probably do a GET http request.
   </synopsis>
  </putter>

  <putter
 	name="new" >
   <title>Create a New Account</title>
   <synopsis>
    Create a new SetSpace account.
   </synopsis>
   <vars>
    <var
    	name="role"
	perl5_new="\w[\w.-]*(?:@\w[\w.-]+)?"
	required="yes"
    />
    <var
    	name="passwd"
	perl5_new="[[:graph:]]1,32}"
	required="yes"
    />
    <var
    	name="passwdv"
	perl5_new="[[:graph:]]1,32}"
	required="yes"
    />
   </vars>
  </putter>

  <putter
 	name="login" >
   <title>Create Login Cookie</title>
   <vars>
    <var
    	name="role"
	perl5_new="\w[\w.-]*(?:@\w[\w.-]+)?"
	required="yes"
    />
    <var
    	name="passwd"
	perl5_new="[[:graph:]]1,32}"
	required="yes"
    />
   </vars>
  </putter>

  <putter
 	name="logout" >
   <title>Delete Login Cookie</title>
  </putter>

 </in>
</POST>
</cgi>
