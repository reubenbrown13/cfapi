<cfheader name="Access-Control-Allow-Origin" value="*">
<cfset SetEncoding("URL", "utf-8" )>

<!--- Variable definitions --->
<cfset query = "" />
<cfset filter = "" />
<cfset EOL="#chr(13)##chr(10)#">
<cfset token = "" />
<cfset nameField="[[*nameFieldForKml*]]">
<cfset firstRow=true>

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
		
	<cfset oldLocale=setLocale("en")>
   <cfset fields="[[*viewFields*]]">
	
<!--- For each view field, create one placemark in KML --->	
<cfsavecontent variable="sFileContent"><?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
<cfoutput query="query"><cfif #isNumeric(query.longitude)# and #isNumeric(query.latitude)#><cfset output=Evaluate("query.#nameField#")><cfset output=ReplaceNoCase("#output#", "&", "&amp;", "all")><cfif #firstRow# EQ true><LookAt>
   <longitude>#query.longitude#</longitude>
   <latitude>#query.latitude#</latitude>
   <altitude>0</altitude>
   <heading>0</heading>
   <tilt>0</tilt>
   <range>100000</range>
   <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
</LookAt><cfset firstRow=false></cfif>   
<Placemark>
   <name>#output#</name>
   <ExtendedData>
<cfloop index="ListElement" list="#fields#" delimiters=","><cfset output=Evaluate("query.#listElement#")>
      <Data name="#listElement#">
        <value>#output#</value>
      </Data>
</cfloop> 	
    </ExtendedData>
   <Point>
      <coordinates>#query.longitude#,#query.latitude#,0</coordinates>
   </Point>
</Placemark>
</cfif></cfoutput></Document>
</kml></cfsavecontent>
   
	<CFHEADER NAME="Content-Disposition" VALUE="attachment;filename=[[*pluralViewName*]].kml">
   <cfcontent type="application/vnd.google-earth.kml+xml"><cfoutput>#sFileContent#</cfoutput>
   <cffile action="write" file="#GetDirectoryFromPath(GetBaseTemplatePath())#[[*pluralViewName*]].kml" output="#sFileContent#">
