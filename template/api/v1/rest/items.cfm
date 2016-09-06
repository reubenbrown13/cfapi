<cfheader name="Access-Control-Allow-Origin" value="*">
<cfset SetEncoding("URL", "UTF-8" )>

<!--- Variables definitions --->
<cfset query = "" />
<cfset filter = "" />
<cfset pretty = "" />
<cfset token = "" />
<cfset array[[*viewName*]]=ArrayNew(1)>
<cfset i=0>

<!--- List of arguments --->
<cfif isDefined("url.filter")>
	<cfset filter="#url.filter#">
</cfif>

<cfif isDefined("url.token")>
   <cfset token = "#url.token#" />
</cfif>

<cfif isDefined("url.pretty")>
	<cfset pretty=#url.pretty#>
</cfif>

<!--- Sometimes when field is left blank, the field name is sent as its value --->						
<cfif lcase(token) EQ "token">
	<cfset token="">
</cfif>									
<cfif lcase(filter) EQ "filter">
	<cfset filter="">
</cfif>					
<cfif lcase(pretty) EQ "pretty">
	<cfset pretty="">
</cfif>					

<!--- Arguments validation --->
<cfif #len(token)# EQ 0>
   <cfheader statuscode="500" statustext="The access token is mandatory." >
   The access token is mandatory.
   <cfabort>   
</cfif>

<!--- Token validation --->
<cftry>
	   <cfinvoke component="[[*apiName*]].data.validationGateway" method="validateToken" returnvariable="valid" token="#token#">
       <cfif #valid# EQ "false">
		   <cfheader statuscode="500" statustext="Invalid token." >
		   Invalid token.
		   <cfabort>   
    </cfif>		
<cfcatch>
	   <cfheader statuscode="500" statustext="Error validating token." >
	   Error validating token.
	   <cfabort>   
</cfcatch>
</cftry>  
	
		
<!--- Get data for external availability as standard JSON --->
<cftry>
   <cfinvoke component="[[*apiName*]].data.[[*viewName*]]Gateway" method="getDataFromCache[[*viewName*]][[*apiName*]]" searchValue="#filter#" returnvariable="query">
<cfcatch>
   <cfheader statuscode="500" statustext="Internal server error." >
   Internal server error.
   <cfabort>   
</cfcatch>	  	  	
</cftry>
	
<cfset oldLocale=setLocale("en")>

<!--- Create the DTO --->
<cfloop query="query">

   <!--- Instantiate object from class [[*viewName*]] --->
   <cfobject name="[[*viewName*]]DTO" component="[[*apiName*]].dto.[[*viewName*]]">

	<cfloop index = "ListElement" list = "[[*viewFields*]]" delimiters = ",">
	
	   <cfoutput>
	      <cfset varValue = toString(Evaluate( "query.#listElement#" ))>
		   <cfset resultado = #Evaluate( " [[*viewName*]]DTO.#listElement# = varValue ")# > 
		</cfoutput>    
	</cfloop>	 		      
      
   <!--- Add the object to an array that will be returned at the end of the method --->
   <cfset i = i + 1>
   <cfset array[[*viewName*]][i]=[[*viewName*]]DTO>  
      
</cfloop>

<cfif arrayLen(array[[*viewName*]]) EQ 0>
   <cfheader statuscode="404" statustext="No records found." >
   No records found
   <cfabort>
</cfif>

<cfscript>
	paths = arrayNew(1);

	paths[1] = expandPath("..\..\..\lib\gson-2.3.1.jar");

	loader = createObject("component", "[[*apiName*]].javaloader.JavaLoader").init(paths);

	if (pretty != "true")
	{
	   Gson = loader.create("com.google.gson.Gson");
	   gson = Gson.init();
	}
	else
	{		
      gson = loader.create("com.google.gson.GsonBuilder");
      gson = gson.setPrettyPrinting().create();
	}  
		
</cfscript>

<!--- Return the JSON --->
<cfif #pretty# EQ "true"><cfcontent type="text/html; charset=utf-8"><cfsavecontent variable="outputJSON"><pre><cfoutput>#trim(gson.toJson(array[[*viewName*]]))#</cfoutput></pre></cfsavecontent></cfif>
<cfif #pretty# NEQ "true"><cfcontent type="application/json; charset=utf-8"><cfsilent><cfsavecontent variable="outputJSON"><cfoutput>#trim(gson.toJson(array[[*viewName*]]))#</cfoutput></cfsavecontent></cfsilent></cfif>
<cfoutput>#outputJSON#</cfoutput>