<cfif isDefined("url.getProtoFile")>
	<cfset getProtoFile="#url.getProtoFile#">
	<cfif lcase(getProtoFile) EQ "getProtoFile">
		<cfset getProtoFile="">
	</cfif>			
<cfelse>
	<cfset getProtoFile="">
</cfif>

<cfif #lcase(getProtoFile)# NEQ "yes" >
	
		
	<cfif isDefined("url.filter")>
		<cfset filter="#url.filter#">
		<cfif lcase(filter) EQ "filter">
			<cfset filter="">
		</cfif>			
	<cfelse>
		<cfset filter="">
	</cfif>
	
	<cfif #len(filter)# EQ 0>
		<cflock type="readOnly" timeout="1" name="LockBinCache[[*viewName*]][[*apiName*]]" throwontimeout="false">
		<cftry>
			<cfset input=#server.cache[[*viewName*]][[*apiName*]]Binary#>
		<cfcatch type="any">
		</cfcatch>
		</cftry>
		</cflock> 
		
	   <cfscript>		
	
			baos = CreateObject("java", "java.io.ByteArrayOutputStream").Init();
						
			input.build().writeTo(baos);
			output = baos.toByteArray();
	
	   </cfscript>	
		
	<cfelse>
	   <cfinvoke component="[[*apiName*]].data.[[*viewName*]]Gateway" method="get[[*viewName*]][[*apiName*]]BinaryData" returnvariable="output" filter="#filter#">
	</cfif> 
	<cfcontent type="application/x-protobuf" variable="#output#">

<cfelse>
		<CFHEADER NAME="Content-Disposition" VALUE="attachment;filename=[[*viewName*]].proto">
      <cfcontent type="text/plain" file="#GetDirectoryFromPath(GetBaseTemplatePath())#..\..\..\proto\[[*viewName*]].proto" />	
</cfif>
