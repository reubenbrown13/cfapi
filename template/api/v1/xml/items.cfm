<cfheader name="Access-Control-Allow-Origin" value="*">
<cfset SetEncoding("URL", "utf-8" )>

<!--- Variable definitions --->
<cfset query = "" />
<cfset filter = "" />
<cfset EOL="#chr(13)##chr(10)#">
<cfset token = "" />
<cfset viewName="[[*viewName*]]">
<cfset firstRow=true>
<cfset download = "false" />

<!--- List of arguments --->
<cfif isDefined("url.filter")>
	<cfset filter="#url.filter#">
</cfif>

<cfif isDefined("url.download")>
   <cfset download = "#url.download#" />
</cfif>

<cfif isDefined("url.token")>
   <cfset token = "#url.token#" />
</cfif>

<!--- Sometimes when field is left blank, the field name is sent as its value --->
<cfif lcase(token) EQ "token">
	<cfset token="">
</cfif>
<cfif lcase(download) EQ "download">
	<cfset download="">
</cfif>	
<cfif lcase(filter) EQ "filter">
	<cfset filter="">
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

		
	<!--- Get data for external availability as CSV --->
	<cftry>
	   <cfinvoke component="[[*apiName*]].data.[[*viewName*]]Gateway" method="getDataFromCache[[*viewName*]][[*apiName*]]" searchValue="#filter#" returnvariable="query">
	<cfcatch>
	   <cfheader statuscode="500" statustext="Internal server error." >
	   Internal server error.
	   <cfabort>   
	</cfcatch>	  	  	
	</cftry>
		
	<cfset oldLocale=setLocale("en")>
	<cfset fields="[[*viewFields*]]">

	<cfset cset = "">	
	<cfscript>
      encoder = createObject("java", "java.nio.charset.Charset");

      cset=encoder.defaultCharset();
   </cfscript>	
	
<!--- Create the XML output --->
<cfsavecontent variable="xmlOutput"><cfoutput><?xml version="1.0" encoding="#cset#"?></cfoutput>
<cfoutput><#viewName#></cfoutput>
<cfloop query="query">   <item><cfoutput><cfloop index="ListElement" list="#fields#" delimiters=","></cfoutput><cfoutput><cfset output=Evaluate("query.#listElement#")></cfoutput>
<cfoutput>	  <#listElement#>#output#</#listElement#></cfoutput></cfloop>
   </item>
</cfloop><cfoutput></#viewName#>
</cfoutput></cfsavecontent>
 	 
<cfif #download# NEQ "false">
	<CFHEADER NAME="Content-Disposition" VALUE="attachment;filename=[[*pluralViewName*]].xml">
   <cfcontent type="text/xml"><cfoutput>#xmlOutput#</cfoutput>
   <cffile action="write" file="#GetDirectoryFromPath(GetBaseTemplatePath())#[[*pluralViewName*]].xml" output="#toString(xmlOutput)#">
<cfelse>
<cfcontent type="text/xml"><cfoutput>#toString(xmlOutput)#</cfoutput>
</cfif>