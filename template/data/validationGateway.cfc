
<cfcomponent displayname="validation">

   <cffunction name="validateToken"
			      returntype="boolean"
			      hint="Verifies if token is valid"
			      access="public"
			      output="false">      

     <!--- List of arguments --->
	  <cfargument name="token" type="string" required="true">
	  
	  <!--- Variables declarations --->
	  <cfset var result=false>
			       
     <cfif #ucase(token)# eq "[[*accessToken*]]">
	 	     <cfset result=true>
  	  <cfelse>
		  <cfset result=false>
  	  </cfif>

	  <!--- Return result --->
	  <cfreturn result>
   
   </cffunction>
 
</cfcomponent>
