<cfheader name="Access-Control-Allow-Origin" value="*">
<cfset SetEncoding("URL", "utf-8" )>

<!--- Variable definitions --->
<cfset query = "" />
<cfset filter = "" />
<cfset EOL="#chr(13)##chr(10)#">
<cfset token = "" />
<cfset nameField="[[*nameFieldForKml*]]">

<!--- List of arguments --->
<cfif isDefined("url.filter")>
	<cfset filter="#url.filter#">
</cfif>

<cfif isDefined("url.token")>
   <cfset token = "#url.token#" />
</cfif>

<!--- Sometimes when field is left blank, the field name is sent as its value --->
<cfif lcase(token) EQ "token">
	<cfset token="">
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
		
<!--- Return 404 if no records found --->
<cfif #query.recordCount# EQ 0>
   <cfheader statuscode="404" statustext="No records found." >
   No records found
   <cfabort>
</cfif>		
		
	<cfset oldLocale=setLocale("en")>
	<cfset fields="[[*viewFields*]]">
	
<!--- For each view field, create one placemark in KML --->	
<cfsavecontent variable="GeoJSON_Output">{ "type": "FeatureCollection",
    "features":
	 [
<cfoutput query="query">
  <cfif #isNumeric(query.longitude)# and #isNumeric(query.latitude)#>
     <cfset output=Evaluate("query.#nameField#")>
     {
        "type": "Feature",
        "geometry":
        {
           "type": "Point", "coordinates": [#query.longitude#, #query.latitude#]
        },
        "properties":
        {
<cfloop index="ListElement" list="#fields#" delimiters=","><cfset output=Evaluate("query.#listElement#")> "#listElement#": "#output#"<cfif not #listLast(fields)# EQ #listElement#>,</cfif></cfloop>
        }
     },
  </cfif>
</cfoutput>]
}</cfsavecontent>
<cfset GeoJSON = #RemoveChars(GeoJSON_Output, GeoJSON_Output.lastIndexOf(',')+1, 1)#>
<cfoutput>#GeoJSON#</cfoutput>