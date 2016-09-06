<cfheader name="Access-Control-Allow-Origin" value="*">
<cfset SetEncoding("URL", "utf-8" )>

<!--- Variable definitions --->
<cfset query = "" />
<cfset filter = "" />
<cfset EOL="#chr(13)##chr(10)#">
<cfset token = "" />
<cfset download = "true" />
<cfset delimiter = ";" />

<!--- List of arguments --->
<cfif isDefined("url.filter")>
	<cfset filter="#url.filter#">
</cfif>

<cfif isDefined("url.token")>
   <cfset token = "#url.token#" />
</cfif>

<cfif isDefined("url.download")>
   <cfset download = "#url.download#" />
</cfif>

<cfif isDefined("url.delimiter")>
   <cfset delimiter = "#url.delimiter#" />
</cfif>

<!--- Sometimes when field is left blank, the field name is sent as its value --->
<cfif lcase(token) EQ "token">
	<cfset token="">
</cfif>									
<cfif lcase(filter) EQ "filter">
	<cfset filter="">
</cfif>					
<cfif lcase(download) EQ "download">
	<cfset download="">
</cfif>
<cfif lcase(delimiter) EQ "delimiter">
	<cfset delimiter=";">
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
	
	<cfset fields="[[*viewFields*]]">
	<cfset fields=ReplaceNoCase(#fields#, ",", "#delimiter#", "all")>
	
	<cfset oldLocale=setLocale("en")>
	<cfsavecontent variable="sFileContent"><cfoutput>#fields##EOL#</cfoutput><cfoutput query="query"><cfsilent>
		<!--- For each view field, create one row --->
		</cfsilent><cfloop index = "ListElement" list = "#fields#" delimiters = "#delimiter#"><cfsilent>
	      <!--- Builds variables dynamically --->
		   <cfset output=Evaluate("query.#listElement#")></cfsilent><cfif findOneOf(',#delimiter#"', #output#)>"#output#"<cfelse>#output#</cfif><cfif #listElement# NEQ listlast(fields,"#delimiter#")>#delimiter#</cfif></cfloop>#EOL#</cfoutput>
	</cfsavecontent>

   <cfif #download# NEQ "false">   
		<CFHEADER NAME="Content-Disposition" VALUE="attachment;filename=[[*pluralViewName*]].csv">
	   <cfcontent type="application/vnd.ms-excel"><cfoutput>#sFileContent#</cfoutput>
	   <cffile action="write" file="#GetDirectoryFromPath(GetBaseTemplatePath())#[[*pluralViewName*]].csv" output="#sFileContent#">
   <cfelse>
<cfoutput>#sFileContent#</cfoutput>   	   
   </cfif>
   
   