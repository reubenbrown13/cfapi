<cfsetting requestTimeout="30000" />
<cfset rootPath="#GetDirectoryFromPath(GetBaseTemplatePath())#">

<!--- Create the tables needed for user reviews/evaluation of api exposed items --->
<cfinvoke component="[[*apiName*]].database.environment" method="createTables">

[[*updateCacheInvokes*]]
[[*updateCacheInvokesForCSV*]]

<h1>Welcome to [[*apiName*]] API</h1>

<h2>Entry points:</h2>

<cfset totalViews = [[*totalDatasources*]]>

<cfoutput>
	<table>
	   <tr>
	      <td><b>CSV</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/csv/#listGetAt("[[*dataSourceNames*]]", i)#.cfm?token=yourAccessToken&filter=&download=true&delimiter=," target="_blank">http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/csv/#listGetAt("[[*dataSourceNames*]]", i)#.cfm?token=yourAccessToken&filter=&download=true&delimiter=,</a></td>
	   </tr>
		</cfloop>
		<tr><td>&nbsp;</td></tr>
	   <tr>
	      <td><b>REST/JSON</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/rest/#listGetAt("[[*dataSourceNames*]]", i)#.cfm?token=yourAccessToken&pretty=false&filter=" target="_blank">http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/rest/#listGetAt("[[*dataSourceNames*]]", i)#.cfm?token=yourAccessToken&pretty=false&filter=</a></td>
	   </tr>
		</cfloop>
		<tr><td>&nbsp;</td></tr>
	   <tr>
	      <td><b>SOAP</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/soap/WS#listGetAt("[[*dataSourceNames*]]", i)#.cfc?wsdl" target="_blank">http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/soap/WS#listGetAt("[[*dataSourceNames*]]", i)#.cfc?wsdl</a></td>
	   </tr>
		</cfloop>		
		<tr><td>&nbsp;</td></tr>
	   <tr>
	      <td><b>XML</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/xml/#listGetAt("[[*dataSourceNames*]]", i)#.cfm?token=yourAccessToken&filter=&download=false" target="_blank">http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/xml/#listGetAt("[[*dataSourceNames*]]", i)#.cfm?token=yourAccessToken&filter=&download=false</a></td>
	   </tr>
		</cfloop>
		
		<cfdirectory
		    action="list"
		    directory="#rootPath#api\[[*apiVersion*]]\kml"
		    recurse="false"
		    name="qFile"
		    filter="*.cfm"
		    />

		<cfif #qFile.recordcount# GT 0>
			<tr><td>&nbsp;</td></tr>
		   <tr>
		      <td><b>KML</b></td>
			</tr>
		</cfif>
		<cfif #qFile.recordcount# GT 0>
			<cfloop query="qFile">			
				<cfif FileExists("#qFile.directory#\#qFile.name#")>
					<tr>
						<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/kml/#qFile.name#?token=yourAccessToken&filter=" target="_blank">http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/kml/#qFile.name#?token=yourAccessToken&filter=</a></td>
				   </tr>
				</cfif>
	      </cfloop>
      </cfif>		
		
		<cfdirectory
		    action="list"
		    directory="#rootPath#api\[[*apiVersion*]]\GeoJSON"
		    recurse="false"
		    name="qFile"
		    filter="*.cfm"
		    />

		<cfif #qFile.recordcount# GT 0>
			<tr><td>&nbsp;</td></tr>
		   <tr>
		      <td><b>GeoJSON</b></td>
			</tr>
		</cfif>
		<cfif #qFile.recordcount# GT 0>
			<cfloop query="qFile">			
				<cfif FileExists("#qFile.directory#\#qFile.name#")>
					<tr>
						<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/GeoJSON/#qFile.name#?token=yourAccessToken&filter=" target="_blank">http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/GeoJSON/#qFile.name#?token=yourAccessToken&filter=</a></td>
				   </tr>
				</cfif>
	      </cfloop>
      </cfif>		

		<tr><td>&nbsp;</td></tr>
	   <tr>
	      <td><b>GOOGLE PROTOCOL BUFFERS (BINARY)</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/binary/#listGetAt("[[*dataSourceNames*]]", i)#.cfm?token=yourAccessToken&filter=&getProtoFile=no" target="_blank">http://localhost/[[*apiName*]]/api/[[*apiVersion*]]/binary/#listGetAt("[[*dataSourceNames*]]", i)#.cfm?token=yourAccessToken&filter=&getProtoFile=no</a></td>
	   </tr>
		</cfloop>
		<tr><td>&nbsp;</td></tr>

		
	</table>

</cfoutput>