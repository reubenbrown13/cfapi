
<cfset rootPath="#GetDirectoryFromPath(GetBaseTemplatePath())#">

<cfset apiName="#form.apiName#">
<cfset apiVersion="#form.apiVersion#">
<cfset viewName="#form.viewName#">
<cfset pluralViewName="#form.pluralViewName#">
<cfset dataSourceName="#form.dataSourceName#">
<cfset searchFilter="#form.searchFilter#">
<cfset searchFilterType="#form.searchFilterType#">
<cfset searchFilterSize="#form.searchFilterSize#">
<cfset accessToken="#form.accessToken#">
<cfset daysInCache="#form.daysInCache#">
<cfset hoursInCache="#form.hoursInCache#">
<cfset minutesInCache="#form.minutesInCache#">
<cfset secondsInCache="#form.secondsInCache#">
<cfset sourcePath="#rootPath#template">
<cfset tempPath="#rootPath#temp\#apiName#">
<cfset destinationPath="#rootPath#api">

<cfset CSVSearchFilter="#form.CSVSearchFilter#">
<cfset CSVSearchFilterType="#form.CSVSearchFilterType#">
<cfset CSVSearchFilterSize="#form.CSVSearchFilterSize#">
<cfset CSVDaysInCache="#form.CSVDaysInCache#">
<cfset CSVHoursInCache="#form.CSVHoursInCache#">
<cfset CSVMinutesInCache="#form.CSVMinutesInCache#">
<cfset CSVSecondsInCache="#form.CSVSecondsInCache#">

<cfif isDefined("form.createAndroidClient")>
   <cfset createAndroidClient="#form.createAndroidClient#">
<cfelse>
   <cfset createAndroidClient=false>
</cfif>

<cfif isDefined("form.createCsvSourced")>
   <cfset createCsvSourced="#form.createCsvSourced#">
<cfelse>
   <cfset createCsvSourced=false>
</cfif>

<cfif isDefined("form.createDatabaseSourced")>
   <cfset createDatabaseSourced="#form.createDatabaseSourced#">
<cfelse>
   <cfset createDatabaseSourced=false>
</cfif>

<cfset viewForAndroid="#form.viewForAndroid#">
<cfset endPointDomain="#form.endPointDomain#">
<cfset initialMapLatitude="#form.initialMapLatitude#">
<cfset initialMapLongitude="#form.initialMapLongitude#">

<cfset CSVFileList="">

<!--- Verify if all fields are filled --->
<cfif len(#apiName#)EQ 0>
   <h2>The API Name is mandatory</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#apiVersion#)EQ 0>
   <h2>The API Version must be informed</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#dataSourceName#)EQ 0>
   <h2>A datasource must be informed</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#viewName#)EQ 0>
   <h2>View name is mandatory</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#pluralViewName#)EQ 0>
   <h2>Plural View Name must be informed</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#searchFilter#)EQ 0>
   <h2>Search Filter field is mandatory</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#searchFilterType#)EQ 0>
   <h2>Search Filter Type is mandatory</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#searchFilterSize#)EQ 0>
   <h2>Search Filter Size is mandatory</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#daysInCache#)EQ 0>
   <h2>Days in Cache must be set</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#hoursInCache#)EQ 0>
   <h2>Hours in Cache must be set</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#minutesInCache#)EQ 0>
   <h2>Minutes in Cache must be set</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#secondsInCache#)EQ 0>
   <h2>Seconds in Cache must be set</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif len(#accessToken#)EQ 0>
   <h2>An access token must be specified</h2>
   Return to <span onClick="history.back();" style="cursor:pointer;color:blue;text-decoration:underline;">previous page</span> and try to make ajustments.
   <cfabort>	
</cfif>

<cfif #len(form.field1)# GT 0>
	<cfset i=1>
	<cfloop condition="isDefined('form.field#i#') EQ true" >
	
		<!--- Copy files to temp folder --->
		<cffile action = "upload" 
		fileField = "form.field#i#" 
		destination = "#sourcePath#\data\csv\" 
		nameConflict = "overwrite" result="result">
	
	   <cfset CSVFileList = CSVFileList & #result.serverFile# & ','>
	
	   <cfset i = i + 1>
	</cfloop>
	<cfset CSVFileList = #RemoveChars(CSVFileList, CSVFileList.lastIndexOf(',')+1, 1)#>
</cfif>

<!--- Generate API dinamically --->
<cfinvoke component="cfc.generator" method="generateApi" apiName="#apiName#"
		                                              apiVersion="#apiVersion#"
                                                    viewName="#viewName#"
		                                              pluralViewName="#pluralViewName#"
                                                    dataSourceName="#dataSourceName#"
                                                    searchFilter="#searchFilter#"
                                                    searchFilterType="#searchFilterType#"
                                                    searchFilterSize="#searchFilterSize#"
                                                    accessToken="#accessToken#"
                                                    sourcePath="#sourcePath#"
                                                    tempPath="#tempPath#"
                                                    destinationPath="#destinationPath#"
		                                              daysInCache="#daysInCache#"
		                                              hoursInCache="#hoursInCache#"
                                                    minutesInCache="#minutesInCache#"
                                                    secondsInCache="#secondsInCache#"
		                                              createAndroidClient="#createAndroidClient#"
		                                              viewForAndroid="#viewForAndroid#"
		                                              endPointDomain="#endPointDomain#"
		                                              initialMapLatitude="#initialMapLatitude#"
                                                    initialMapLongitude="#initialMapLongitude#"
		                                              returnvariable="result"
		                                              CSVFileList="#CSVFileList#"
																	 CSVSearchFilter="#form.CSVSearchFilter#"
																	 CSVSearchFilterType="#CSVSearchFilterType#"
																	 CSVSearchFilterSize="#CSVSearchFilterSize#"
																	 CSVDaysInCache="#CSVDaysInCache#"
																	 CSVHoursInCache="#CSVHoursInCache#"
																	 CSVMinutesInCache="#CSVMinutesInCache#"
																	 CSVSecondsInCache="#CSVSecondsInCache#"
		                                              createDatabaseSourced="#createDatabaseSourced#"
		                                              createCsvSourced="#createCsvSourced#">
													    

														 
<html>

   <body>

<cfoutput>

<cfif #result# EQ true>
   <h2>API #apiName# created successfully!</h2>
	<br>
	Next steps are:<br>
	<br>
	1. <a href="/CFapi/api/#apiName#.zip">Click here to download your API PROJECT zip file.</a><br>
	2. Extract the contents of your API PROJECT zip file and deploy to your server.<br>
	3. Create application database and datasource for user reviews of api exposed items (not needed in Railo or Lucee):<br>
	   <cfform action="http://localhost/#apiName#/database/createdb.cfm" method="post" target="_blank">
	   &nbsp;&nbsp;&nbsp;CFAdmin password: <cfinput type="password" name="authorization" value="">
	   <cfinput type="submit" name="btnCreate" value="Create DB"></cfform>
	4. Call <a href="http://localhost/#apiName#/index.cfm" target="_blank">http://localhost/#apiName#/index.cfm</a> to do initial load of memory caches (on Railo or Lucee, remember to add port 8888 to localhost).<br>
	5. Create a Coldfusion Scheduled Task to update your caches from time to time.<br>
	&nbsp;&nbsp;&nbsp;There is a file (updateCache.cfm) on your project folder (ScheduledTasks) ready to be called by your scheduled task.<br>
   6. Try out your API!<br>
	<cfif #createAndroidClient# EQ true>
	   6. Your Android APP is located in "clients" folder of your API PROJECT zip file.<br>
	</cfif> 
   <br>
   
	<table>
	<tr><td style="background-color:lightGrey;padding:10px;color:black;text-decoration:bold;">Your access token is : <input type="text" style="background-color:lightGrey;font-size:16px;padding:5px;border:none;width:330px;" onclick="this.select();" value="#accessToken#" readonly="readonly"></td></tr>
	</table>
	<br>
		
	<h3>Your #apiName# API has CSV, REST/JSON, SOAP, XML, KML and GeoJSON entry points, as follows:</h3>

   <cfset dataSourceNames = "">
   <cfset dataSourceNamesCsv = "">
   
	<cfif #createCsvSourced#>
	   <cfset totalCSVs = listLen(#CSVFileList#, ",")>
	   <cfset dataSourceNamesCsv =  Replace(CSVFileList, ".csv", "", "all")>
	<cfelse>
	   <cfset totalCSVs = listLen(#CSVFileList#, ",")>
	</cfif>
	
	<cfif #createDatabaseSourced#>
	   <cfset totalViews = listLen(#viewName#, ",")>
	   <cfset dataSourceNames = pluralViewName>
	<cfelse>
		<cfset totalViews = 0>
	</cfif>
		
	<cfset totalViews = totalViews + totalCSVs>
	
	<cfif totalCSVs GT 0>
	   <cfset dataSourceNames = dataSourceNames & "," & dataSourceNamesCsv>
	</cfif>
	
	<table>
	   <tr>
	      <td><b>CSV</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/#apiName#/api/#apiVersion#/csv/#listGetAt(dataSourceNames, i)#.cfm?token=#accessToken#&filter=&download=true&delimiter=," target="_blank">http://localhost/#apiName#/api/#apiVersion#/csv/#listGetAt(dataSourceNames, i)#.cfm?token=#accessToken#&filter=&download=true&delimiter=,</a></td>
	   </tr>
		</cfloop>
		<tr><td>&nbsp;</td></tr>
	   <tr>
	      <td><b>REST/JSON</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/#apiName#/api/#apiVersion#/rest/#listGetAt(dataSourceNames, i)#.cfm?token=#accessToken#&pretty=false&filter=" target="_blank">http://localhost/#apiName#/api/#apiVersion#/rest/#listGetAt(dataSourceNames, i)#.cfm?token=#accessToken#&pretty=false&filter=</a></td>
	   </tr>
		</cfloop>
		<tr><td>&nbsp;</td></tr>
	   <tr>
	      <td><b>SOAP</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/#apiName#/api/#apiVersion#/soap/WS#listGetAt(dataSourceNames, i)#.cfc?wsdl" target="_blank">http://localhost/#apiName#/api/#apiVersion#/soap/WS#listGetAt(dataSourceNames, i)#.cfc?wsdl</a></td>
	   </tr>
		</cfloop>
		<tr><td>&nbsp;</td></tr>
	   <tr>
	      <td><b>XML</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/#apiName#/api/#apiVersion#/xml/#listGetAt(dataSourceNames, i)#.cfm?token=#accessToken#&filter=&download=false" target="_blank">http://localhost/#apiName#/api/#apiVersion#/xml/#listGetAt(dataSourceNames, i)#.cfm?token=#accessToken#&filter=&download=false</a></td>
	   </tr>
		</cfloop>

		<cfif #len(application.kmlFiles)# GT 0>
			<tr><td>&nbsp;</td></tr>
		   <tr>
		      <td><b>KML</b></td>
			</tr>		
	      <cfloop index = "element" list = "#application.kmlFiles#" delimiters = ",">
				<tr>
					<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/#apiName#/api/#apiVersion#/kml/#element#.cfm?token=#accessToken#&filter=" target="_blank">http://localhost/#apiName#/api/#apiVersion#/kml/#element#.cfm?token=#accessToken#&filter=</a></td>
			   </tr>         
			</cfloop>		
		</cfif>

		<cfif #len(application.geoFiles)# GT 0>
			<tr><td>&nbsp;</td></tr>
		   <tr>
		      <td><b>GeoJSON</b></td>
			</tr>		
	      <cfloop index = "element" list = "#application.geoFiles#" delimiters = ",">
				<tr>
					<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/#apiName#/api/#apiVersion#/GeoJSON/#element#.cfm?token=#accessToken#&filter=" target="_blank">http://localhost/#apiName#/api/#apiVersion#/GeoJSON/#element#.cfm?token=#accessToken#&filter=</a></td>
			   </tr>         
			</cfloop>		
		</cfif>

		<tr><td>&nbsp;</td></tr>
	   <tr>
	      <td><b>GOOGLE PROTOCOL BUFFERS (BINARY)</b></td>
		</tr>
		<cfloop from="1" to="#totalViews#" index="i">
		<tr>
			<td>&nbsp;&nbsp;&nbsp;<a href="http://localhost/#apiName#/api/#apiVersion#/binary/#listGetAt(dataSourceNames, i)#.cfm?token=#accessToken#&filter=&getProtoFile=no" target="_blank">http://localhost/#apiName#/api/#apiVersion#/binary/#listGetAt(dataSourceNames, i)#.cfm?token=#accessToken#&filter=&getProtoFile=no</a></td>
	   </tr>
		</cfloop>

		
		<tr><td>&nbsp;</td></tr>
	</table>
	
<div style="text-align:justify;text-justify:inter-word;width:60%;">
	From now on, you can modify/extend/improve your API as an independent project. This API is prepared for heavy load
	consuming. It is based on ETL (Extract, Transform and Load) and anticipated consuming, that grabs data from
	database from time to time and stores it on memory caches, making data available as fast as possible for consumers
	in a variety of formats, like CSV, REST/JSON, SOAP, XML, KML, GeoJSON and GOOGLE PROTOCOL BUFFERS (BINARY).
	Please restart Coldfusion Application Service before re-generating API (because of JavaLoader compiler),
	otherwise some classes needed for Google Protocol Buffers might not get created.<br>
	</div>
<cfelse>
   Sorry, there was an error and your #apiName# API could not be created. 	
</cfif>

</cfoutput>

   </body>
</html>
