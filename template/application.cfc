<!---

   Project : API [[*apiName*]] created with CFapi.
             CFapi Dynamic API generator created by Luiz Milfont in 29/09/2015.
 
 --->

<cfcomponent
    displayname="[[*apiName*]]"
    output="true">


<!--- Set application configuration --->
<cfset THIS.Name = "[[*apiName*]]" />
<cfset THIS.SessionTimeout = CreateTimeSpan( 0, 0, 20, 0 ) />
<cfset THIS.SessionManagement = true />
<cfset THIS.ClientManagement = false />
<cfset THIS.LoginStorage = "session" />

<!--- Set default charset to UTF-8 --->
<cfprocessingdirective pageencoding="UTF-8">
<cfcontent type="text/html; charset=UTF-8">
<cfset setEncoding("URL", "UTF-8")>
<cfset setEncoding("Form", "UTF-8")>
	
<cfset cfmlServer="#SERVER.coldfusion.productname#">

<cfif findNoCase("coldfusion", cfmlServer) EQ 0>
	<cfscript>
		this.datasources["[[*apiName*]]Dynamic"] =
		{
		    class= 'org.h2.Driver'
		    ,connectionString= 'jdbc:h2:#expandPath("[[*apiName*]]/database/[[*apiName*]]")#;MODE=MySQL'
	   };
	</cfscript>
</cfif>	
	
<cffunction
        name="OnApplicationStart"
        access="public"
        returntype="boolean"
        output="false">

		<!--- Create empty memory cache for each database view ---> 
		[[*memoryCacheDefinitions*]]
		
		[[*memoryCacheDefinitionsForCSV*]]
		
		[[*memoryCacheDefinitionsForGPB*]]

        
        <cfreturn true />
    </cffunction>	

	

</cfcomponent>
