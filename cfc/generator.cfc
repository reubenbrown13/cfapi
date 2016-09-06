<cfcomponent output="no" displayname="generator">
<cfprocessingdirective pageencoding = "UTF-8" />

	<cffunction name="generateApi" access="remote" hint="Creates a new API, automatically." returntype="boolean">
	   <cfargument name="apiName" type="string" required="yes">
	   <cfargument name="apiVersion" type="string" required="yes">
		<cfargument name="viewName" type="string" required="yes">
		<cfargument name="pluralViewName" type="string" required="yes">
		<cfargument name="dataSourceName" type="string" required="yes">
		<cfargument name="searchFilter" type="string" required="yes">
		<cfargument name="searchFilterType" type="string" required="yes">
		<cfargument name="searchFilterSize" type="string" required="yes">
		<cfargument name="accessToken" type="string" required="yes">
      <cfargument name="sourcePath" type="string" required="yes">
      <cfargument name="tempPath" type="string" required="yes">
      <cfargument name="destinationPath" type="string" required="yes">
	   <cfargument name="daysInCache" type="string" required="yes">
	   <cfargument name="hoursInCache" type="string" required="yes">
		<cfargument name="minutesInCache" type="string" required="yes">
		<cfargument name="secondsInCache" type="string" required="yes">
		<cfargument name="createAndroidClient" type="string" required="yes">
		<cfargument name="viewForAndroid" type="string" required="yes">
		<cfargument name="endPointDomain" type="string" required="yes">
		<cfargument name="initialMapLatitude" type="string" required="yes">
		<cfargument name="initialMapLongitude" type="string" required="yes">
		<cfargument name="CSVFileList" type="string" required="yes">
		<cfargument name="CSVSearchFilter" type="string" required="yes">
		<cfargument name="CSVSearchFilterType" type="string" required="yes">
		<cfargument name="CSVSearchFilterSize" type="string" required="yes">
	   <cfargument name="CSVDaysInCache" type="string" required="yes">
	   <cfargument name="CSVHoursInCache" type="string" required="yes">
		<cfargument name="CSVMinutesInCache" type="string" required="yes">
		<cfargument name="CSVSecondsInCache" type="string" required="yes">
		<cfargument name="createDatabaseSourced" type="string" required="yes">
		<cfargument name="createCsvSourced" type="string" required="yes">


      <!--- Variables declarations --->
      <cfset var result="">
      <cfset var count=1>
      <cfset var currentPluralViewName="">
	   <cfset var dynamicInvokes="">
	   <cfset var dynamicInvokesForCSV="">
	   <cfset var dynamicDefinitions="">
	   <cfset var dynamicDefinitionsForCSV="">
      <cfset var binaryCacheDefinitions="">
	   <cfset var dynamicMethods="">
      <cfset var dynamicMethods2="">
	   <cfset var binaryMethods="">
	   <cfset var CSVMethods="">
      <cfset var foundLatLng=false>
	   <cfset var foundLatLngForCSV=false>
	   <cfset var totalViews = 0> 
      <cfset var totalCSV = 0>
	    
	   <!--- Determine which CFML engine is installed and copy correct files --->
	   <cfset var cfmlServer="#SERVER.coldfusion.productname#">
      
      <cfif findNoCase("coldfusion", cfmlServer) GT 0>
	  	   <cfset cfmlServer="cf">
	  	<cfelseif findNoCase("railo", cfmlServer) GT 0>
		   <cfset cfmlServer="railo">
		<cfelseif findNoCase("lucee", cfmlServer) GT 0>     
	      <cfset cfmlServer="lucee">
	   </cfif>

		<cfif cfmlServer EQ "railo">
		   <cffile action="copy" source="#expandPath('javaloader\lib\tools_railo.jar')#" destination="#expandPath('javaloader\lib\tools.jar')#">
		<cfelseif cfmlServer EQ "lucee">
		   <cffile action="copy" source="#expandPath('javaloader\lib\tools_lucee.jar')#" destination="#expandPath('javaloader\lib\tools.jar')#">
		<cfelseif cfmlServer EQ "cf">
		   <cffile action="copy" source="#expandPath('javaloader\lib\tools_coldfusion.jar')#" destination="#expandPath('javaloader\lib\tools.jar')#">
		<cfelse>
			<cffile action="copy" source="#expandPath('javaloader\lib\tools_lucee.jar')#" destination="#expandPath('javaloader\lib\tools.jar')#">
		</cfif>
	   
      <!--- Clear kmlFiles and geoFiles variable --->
      <cfset #application.kmlFiles# = "">
	   <cfset #application.geoFiles# = "">

		<!--- Create api temp folder. Then copy all files from template folder to temp folder --->
		<cfif DirectoryExists("#tempPath#")>
		   <cfdirectory action="delete" directory="#tempPath#" recurse="true">
		</cfif>
		<cfdirectory action="create" directory="#tempPath#">
		<cfinvoke method="copyFolder" returnvariable="result" sourceFolder="#sourcePath#" destinationFolder="#tempPath#">
		<!--- End of Createapi temp folder block --->
      
      <cfif #arguments.createDatabaseSourced# EQ "true">

         <!--- For each database view, extract fields, create a query, copy "items" files doing replacements, dynamically --->
         <cfset totalViews = listLen("#arguments.viewName#", ",")> 

	      <cfloop index = "ListElement" list = "#arguments.viewName#" delimiters = ",">
	  	   <cfset currentView = #count#>
	  	   		    
			<!--- Extract view fields, dynamically --->
			<cfdbinfo  
			    type="Columns" table="#listElement#" 
			    datasource="#dataSourceName#" 
			    name="dbdata">
				
			<cfset fields="">
			<cfset varchars="">
			
			<cfquery dbtype="query" name="getDistinctFields">
				select distinct column_name from dbdata
			</cfquery>
				
			<cfoutput query="getDistinctFields">
				<cfset fieldName = "#getDistinctFields.column_name#">
				<cfset fields=fields.concat(#fieldName#)>
				<cfset varchars=varchars.concat("varchar")>
			   <cfif #getDistinctFields.currentRow# NEQ #getDistinctFields.recordcount#>
			      <cfset fields=fields.concat(",")>
			      <cfset varchars=varchars.concat(",")>
			   </cfif>
			</cfoutput>	
			
			<cfset viewFields="#deAccent(fields)#">
			<!--- End of extract fields dynamically --->

	      <!--- Check if current view/table has latitude and longitude fields --->
	      <cfif findNoCase('latitude', "#viewFields#") and findNoCase('longitude', "#viewFields#")>
	         <cfset foundLatLng=true>
	      </cfif>
			
			<!--- Extract plural view name for current view --->         
	      <cfset currentPluralViewName = ListGetAt(#pluralViewName#,count, ",")>
		   <cfset currentSearchFilter = ListGetAt(#arguments.searchFilter#,count, ",")>
	      <cfset currentSearchFilterSize = ListGetAt(#arguments.searchFilterSize#,count, ",")>
	      <cfset currentSearchFilterType = ListGetAt(#arguments.searchFilterType#,count, ",")>			      
			
			<!--- Define feature main query --->
			<cfset dataFetchQuery="select #fields# from #listElement#">

	      <!--- Create one "items" file for each database view, and for each format --->
	      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\csv\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\csv\#currentPluralViewName#.cfm">
					<cffile file="#tempPath#\api\#arguments.apiVersion#\csv\#currentPluralViewName#.cfm" action="read" variable="myFile1">
					<cfset result=Replace(#myFile1#, "[[*apiName*]]", "#arguments.apiName#", "all")>
	            <cfset result=Replace(#result#, "[[*viewName*]]", "#listElement#", "all")>
			      <cfset result=Replace(#result#, "[[*viewFields*]]", "#viewFields#", "all")>
				   <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#currentPluralViewName#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilter*]]", "#currentSearchFilter#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#currentSearchFilterType#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#currentSearchFilterSize#", "all")>				      				      
			      <cffile file="#tempPath#\api\#arguments.apiVersion#\csv\#currentPluralViewName#.cfm" action="write" output="#result#" nameconflict="overwrite">

	      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\rest\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\rest\#currentPluralViewName#.cfm">
					<cffile file="#tempPath#\api\#arguments.apiVersion#\rest\#currentPluralViewName#.cfm" action="read" variable="myFile2">
					<cfset result=Replace(#myFile2#, "[[*apiName*]]", "#arguments.apiName#", "all")>
	            <cfset result=Replace(#result#, "[[*viewName*]]", "#listElement#", "all")>
			      <cfset result=Replace(#result#, "[[*viewFields*]]", "#viewFields#", "all")>
			      <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#currentPluralViewName#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilter*]]", "#currentSearchFilter#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#currentSearchFilterType#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#currentSearchFilterSize#", "all")>				    
			      <cffile file="#tempPath#\api\#arguments.apiVersion#\rest\#currentPluralViewName#.cfm" action="write" output="#result#" nameconflict="overwrite">
               
		   <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\soap\WSItems.cfc" destination="#tempPath#\api\#arguments.apiVersion#\soap\WS#currentPluralViewName#.cfc">
					<cffile file="#tempPath#\api\#arguments.apiVersion#\soap\WS#currentPluralViewName#.cfc" action="read" variable="myFile3">
					<cfset result=Replace(#myFile3#, "[[*apiName*]]", "#arguments.apiName#", "all")>
	            <cfset result=Replace(#result#, "[[*viewName*]]", "#listElement#", "all")>
			      <cfset result=Replace(#result#, "[[*viewFields*]]", "#viewFields#", "all")>
			      <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#currentPluralViewName#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilter*]]", "#currentSearchFilter#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#currentSearchFilterType#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#currentSearchFilterSize#", "all")>				    
			      <cffile file="#tempPath#\api\#arguments.apiVersion#\soap\WS#currentPluralViewName#.cfc" action="write" output="#result#" nameconflict="overwrite">

	      <!--- If current view/table has latitude and longitude fields, then the generated API will provide KML and GeoJSON output  --->
	      <cfif #foundLatLng#>
		      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\kml\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\kml\#currentPluralViewName#.cfm">
						<cffile file="#tempPath#\api\#arguments.apiVersion#\kml\#currentPluralViewName#.cfm" action="read" variable="myFile4">
						<cfset result=Replace(#myFile4#, "[[*apiName*]]", "#arguments.apiName#", "all")>
		            <cfset result=Replace(#result#, "[[*viewName*]]", "#listElement#", "all")>
				      <cfset result=Replace(#result#, "[[*viewFields*]]", "#viewFields#", "all")>
				      <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#currentPluralViewName#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilter*]]", "#currentSearchFilter#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#currentSearchFilterType#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#currentSearchFilterSize#", "all")>
						<cfset result=Replace(#result#, "[[*nameFieldForKml*]]", "#currentSearchFilter#", "all")>
				      <cffile file="#tempPath#\api\#arguments.apiVersion#\kml\#currentPluralViewName#.cfm" action="write" output="#result#" nameconflict="overwrite">
		            <cfset #application.kmlFiles# = #application.kmlFiles# & "#currentPluralViewName#">
					   <cfif #listElement# NEQ listlast(#viewName#, ",")>
					      <cfset #application.kmlFiles# = #application.kmlFiles# & ",">
					   </cfif>

		      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\GeoJSON\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\GeoJSON\#currentPluralViewName#.cfm">
						<cffile file="#tempPath#\api\#arguments.apiVersion#\GeoJSON\#currentPluralViewName#.cfm" action="read" variable="myFile5">
						<cfset result=Replace(#myFile5#, "[[*apiName*]]", "#arguments.apiName#", "all")>
		            <cfset result=Replace(#result#, "[[*viewName*]]", "#listElement#", "all")>
				      <cfset result=Replace(#result#, "[[*viewFields*]]", "#viewFields#", "all")>
				      <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#currentPluralViewName#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilter*]]", "#currentSearchFilter#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#currentSearchFilterType#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#currentSearchFilterSize#", "all")>
						<cfset result=Replace(#result#, "[[*nameFieldForKml*]]", "#currentSearchFilter#", "all")>
				      <cffile file="#tempPath#\api\#arguments.apiVersion#\GeoJSON\#currentPluralViewName#.cfm" action="write" output="#result#" nameconflict="overwrite">
		            <cfset #application.geoFiles# = #application.geoFiles# & "#currentPluralViewName#">
					   <cfif #listElement# NEQ listlast(#viewName#, ",")>
					      <cfset #application.geoFiles# = #application.geoFiles# & ",">
					   </cfif>
		   
		   </cfif>

         <!--- Create the XML files --->
	      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\xml\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\xml\#currentPluralViewName#.cfm">
					<cffile file="#tempPath#\api\#arguments.apiVersion#\xml\#currentPluralViewName#.cfm" action="read" variable="myFile6">
					<cfset result=Replace(#myFile6#, "[[*apiName*]]", "#arguments.apiName#", "all")>
	            <cfset result=Replace(#result#, "[[*viewName*]]", "#listElement#", "all")>
			      <cfset result=Replace(#result#, "[[*viewFields*]]", "#viewFields#", "all")>
			      <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#currentPluralViewName#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilter*]]", "#currentSearchFilter#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#currentSearchFilterType#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#currentSearchFilterSize#", "all")>				    
			      <cffile file="#tempPath#\api\#arguments.apiVersion#\xml\#currentPluralViewName#.cfm" action="write" output="#result#" nameconflict="overwrite">

         <!--- Create Google Protocol Buffers Binary files --->
	      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\binary\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\binary\#currentPluralViewName#.cfm">
					<cffile file="#tempPath#\api\#arguments.apiVersion#\binary\#currentPluralViewName#.cfm" action="read" variable="myFile7">
					<cfset result=Replace(#myFile7#, "[[*apiName*]]", "#arguments.apiName#", "all")>
	            <cfset result=Replace(#result#, "[[*viewName*]]", "#listElement#", "all")>
			      <cfset result=Replace(#result#, "[[*viewFields*]]", "#viewFields#", "all")>
			      <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#currentPluralViewName#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilter*]]", "#currentSearchFilter#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#currentSearchFilterType#", "all")>
					<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#currentSearchFilterSize#", "all")>				    
			      <cffile file="#tempPath#\api\#arguments.apiVersion#\binary\#currentPluralViewName#.cfm" action="write" output="#result#" nameconflict="overwrite">

            
			<!--- Create the DTOs --->
			<cfset oldLocale=setLocale("en")>
			<cfset header='<cfcomponent displayname="#listElement#DTO" hint="#listElement# Class">#chr(13)##chr(10)#'>
			<cfset footer="</cfcomponent>">
			<cfset filename="#tempPath#\DTO\#listElement#.cfc">   
			
			<cffile action="write" file="#filename#" output="#header#">
			
			<cfsavecontent variable="DTOFileContent"><cfloop index = "fieldListElement" list = "#viewFields#" delimiters = ","><cfset row='   <cfproperty name="#fieldListElement#" type="string">#chr(13)##chr(10)#'><cfoutput>#row#</cfoutput></cfloop></cfsavecontent>
			<cffile file="#filename#" action="append" output="#DTOFileContent#">
			<cffile file="#filename#" action="append" output="#footer#">
			<!--- End of block --->


			<!--- Create the .PROTO files (for Google Protocol Buffers binary endpoints) --->
			<cfset oldLocale=setLocale("en")>
			<cfset header="package #arguments.apiName#;#chr(13)##chr(10)#">
			<cfset optJavaPackage='option java_package = "com.#arguments.apiName#.protos";#chr(13)##chr(10)#'>
			<cfset optJavaOuterClassName='option java_outer_classname = "#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Protos" ;#chr(13)##chr(10)#'>
			<cfset filename="#tempPath#\proto\#listElement#.proto">
			
			<cffile action="write" file="#filename#" output="#header#">
			<cffile action="append" file="#filename#" output="#optJavaPackage#">
			<cffile action="append" file="#filename#" output="#optJavaOuterClassName#">
			
			<cfsavecontent variable="protoFileContent">message <cfoutput>#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member#chr(13)##chr(10)#{#chr(13)##chr(10)#</cfoutput><cfset i = 1><cfloop index = "fieldListElement" list = "#viewFields#" delimiters = ","><cfset row='   required string #fieldListElement# = #i#;#chr(13)##chr(10)#'><cfset i = i + 1><cfoutput>#row#</cfoutput></cfloop>}</cfsavecontent>
			<cffile file="#filename#" action="append" output="#protoFileContent#">
			
			<cfsavecontent variable="protoFileContent"><cfoutput>#chr(13)##chr(10)#message #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection#chr(13)##chr(10)#{#chr(13)##chr(10)#</cfoutput><cfset i = 1><cfset row='   repeated #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member #listElement#Member = 1;#chr(13)##chr(10)#'><cfoutput>#row#</cfoutput>}</cfsavecontent>
			<cffile file="#filename#" action="append" output="#protoFileContent#">			
			<!--- End of block --->

         <!--- Compile the .PROTO files for Google Protocol Buffers (Windows executable. Get protoc for Linux if it is your Operating System). --->
	 	   <cfexecute name="#tempPath#\proto\protoc.exe" arguments="--java_out #tempPath#\proto\sources --proto_path #tempPath#\proto #tempPath#\proto\#listElement#.proto" />

         <!--- Generate dynamic invokes for index.cfm and updateCache.cfm files --->
			<cfset row='<cfinvoke component="#arguments.apiName#.data.#replaceNoCase(ListElement,'.csv','','all')#Gateway" method="fillCache#ListElement##apiName#" returnvariable="result">'>
			<cfoutput><cfsavecontent variable="dynamicInvokesRow">#row##chr(13)##chr(10)#</cfsavecontent></cfoutput>
         <cfset dynamicInvokes=dynamicInvokes.concat("#dynamicInvokesRow#")>       
                
         <!--- Generate dynamically memory cache definitions --->
			<cfset row='
			   <cftry>
			 	   <!--- Verify if cache is already defined, otherwhise define it --->  
				      <!--- Set up fields of the cached query, as database view setup ---> 
				      <cfset q = QueryNew("#viewFields#")>
			  		   <cfparam name="server.cache#listElement##apiName#" type="query" default="' & chr(35) & 'q' & chr(35) & '">
				<cfcatch type="any">
				</cfcatch>
				</cftry>'>
			<cfoutput><cfsavecontent variable="dynamicCacheDefinitionRow">#row##chr(13)##chr(10)#</cfsavecontent></cfoutput>
			<cfset dynamicDefinitions=dynamicDefinitions.concat("#dynamicCacheDefinitionRow#")>

         <!--- Generate dynamically memory cache definitions --->
			<cfset row='
				<!--- Creates a memory cache for binary data --->
			   <cftry>  	
						<cfscript>	
							
							paths = arrayNew(1);
						
							paths[1] = expandPath("lib\#apiName#_GoogleProtocolBuffers.jar");
						
							loader = createObject("component", "#apiName#.javaloader.JavaLoader").init(paths);
								
						   #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Protos$#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member");
						   #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Protos$#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection");
						   		   
							#lcase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection = #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection.newBuilder();
														
						   server.cacheBinary#listElement##apiName# = #lcase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection;
						</cfscript>
				<cfcatch type="any">
				</cfcatch>
				</cftry>'>
				
			<cfoutput><cfsavecontent variable="binaryCacheDefinitionRow">#row##chr(13)##chr(10)#</cfsavecontent></cfoutput>
			<cfset binaryCacheDefinitions=binaryCacheDefinitions.concat("#binaryCacheDefinitionRow#")>

         <!--- Generate builder fields setters --->
	      <cfset builderFieldsSetters=""> 
	      <cfloop index = "fieldListElement" list = "#viewFields#" delimiters = ",">
			  <cfset fieldListElementUC = #ucase(left(fieldListElement, 1))# & #mid(fieldListElement, 2, len(fieldListElement) -1 )#>
	  		  <cfset builderFieldsSetters=builderFieldsSetters.concat('#chr(13)##chr(10)##chr(9)#.set#removeUnderscore(fieldListElementUC)#(JavaCast("string", ' & chr(35) & 'dataCache.#fieldListElement#' & chr(35) & ' ))')>
	 	   </cfloop>

         <!--- Generate database gateway methods dynamically --->
			<cfset row='
			 <cffunction name="fillCache#ucase(left(listElement,1))##right(listElement,len(listElement)-1)##apiName#"
			  		       returntype="boolean"
						    hint="Fills the memory cache from the database."
						    access="public"
						    output="false">      
			
					  
			   <!--- Variables declarations --->
				<cfset var dataCache="">
				
				<!--- Clear the memory cache --->
				<cfset dataCache = QueryNew("#viewFields#", "#varchars#")>
			  
			   <!--- Extract data from database --->
			   <cfquery datasource="#arguments.dataSourceName#" name="query">
			      #dataFetchQuery#
			   </cfquery>  
			
			   <!--- Copy each item from the executed query into the memory cache --->
			      <cfloop query="query">
					  	  
			         <!--- Create a row in memory cache --->
			         <cfset newRow = QueryAddRow(dataCache, 1)>
			         
			         <!--- For each view field, copy into the cache, inserting in the created row --->
					   <cfloop index = "elementList" list = "#viewFields#" delimiters = ",">  
			
			            <!--- Copy field to the memory cache --->
							<cfset fieldValue = evaluate( " query.' & chr(35) & 'elementList' & chr(35) & '" )>
						   <cfset temp = QuerySetCell(' & chr(35) & 'dataCache' & chr(35) & ', "' & chr(35) & 'elementList' & chr(35) & '", javacast( "string", "' & chr(35) & 'fieldValue' & chr(35) & '") )>
			      		    
					   </cfloop>	  
					         	
			      
			      </cfloop>
			
			      <!--- Move data from temp area to real server cache --->
			
			      <!--- Here we have to lock the code --->
			      <cflock type="exclusive" timeout="10" name="LockCache#listElement##apiName#" throwontimeout="false">
			         <cftry>
			            <!--- Recreate the data cache --->
			            <cfset server.cache#listElement##apiName# = ' & chr(35) & 'dataCache' & chr(35) & '>
			         <cfcatch type="any">
			         </cfcatch>	 
			         </cftry>
			 	   </cflock>
			           
			      <!--- Create in memory a binary collection for Google Protocol Buffers consuming --->
					<cfscript>
							
				
						paths = arrayNew(1);
					
						// Define the JARs involved.
						paths[1] = expandPath("lib\#apiName#_GoogleProtocolBuffers.jar");
					
						// Javaloader is needed to get the required JARs without changing Coldfusion Administrator classpath.
						loader = createObject("component", "#apiName#.javaloader.JavaLoader").init(paths);
													
					   // Create the required class instances to build the binary cache.
					   #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Protos$#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member");
					   #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Protos$#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection");
					   
				      #lcase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection = #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection.newBuilder();
					   					   	 		
					</cfscript>
				
					<!--- Iterate over the query cache, generating items to fill the binary cache --->
					<cfloop query="dataCache">
					
						<cfscript>
							
							// Create a new object.
					      #lcase(left(listElement,1))##right(listElement,len(listElement)-1)#Member = #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member.newBuilder() ' & #builderFieldsSetters# & '
						   .build();	   
					      
					      // Add the object to collection.
					      #lcase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection.add#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member(#lcase(left(listElement,1))##right(listElement,len(listElement)-1)#Member);
						</cfscript>
					
					</cfloop>
								
			      <!--- Copy the created collection to the real binary cache --->
			      <cflock type="exclusive" timeout="5" name="LockBinCache" throwontimeout="false">
			         <cftry>
			            <cfset server.cache#listElement##apiName#Binary = ' & chr(35) & '#lcase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection' & chr(35) & '>
			         <cfcatch type="any">
			         </cfcatch>	 
			         </cftry>
				   </cflock>     
			           
			      <!--- Empty temp variables --->
			      <cfset cacheForBinary="">
			      <cfset dataCache="">
			      <cfset #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member = "">
			      <cfset #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection = "">
			      <cfset loader=""> 
			
				   <!--- Return --->
				   <cfreturn true>
			      
			   </cffunction>
                          '>
                          
            <cfset row2 = '
				   <cffunction name="getDataFromCache#ucase(left(listElement,1))##right(listElement,len(listElement)-1)##apiName#"
					 		      returntype="query"
							      hint="Gets data from memory cache."
							      access="public"
							      output="false">      
				
				      <!--- List of arguments --->
					   <cfargument name="searchValue" type="string" required="false">
					      
						<!--- Variables declarations ---> 
				      <cfset var q = "">
				      <cfset var tempQuery = QueryNew("#viewFields#")>
				      <cfset searchValue = lcase(searchValue)>
					
				      <cflock type="readOnly" timeout="1" name="LockCache#listElement##apiName#" throwontimeout="false">
					     <cftry>
						    <cfset tempQuery=server.cache#listElement##apiName#>
					     <cfcatch>
						  </cfcatch>
						  </cftry>
				 	   </cflock>     	
				
					   <cfoutput>
					   <cfquery dbtype="query" name="q" timeout="10">
					      select #viewFields#
						   from tempQuery
					      <cfif len(' & chr(35) & 'arguments.searchValue' & chr(35) & ') GT 0>
					         <cfif "#currentSearchFilterType#" EQ "numeric">     
					            where CAST("#currentSearchFilter#" as DOUBLE) = CAST(<cfqueryparam value="' & chr(35) & 'arguments.searchValue' & chr(35) & '" cfsqltype="cf_sql_varchar" maxlength="#currentSearchFilterSize#" null="false"> as DOUBLE)
						      </cfif>
				            <cfif "#currentSearchFilterType#" EQ "string">
				               where lower(#currentSearchFilter#) = <cfqueryparam value="' & chr(35) & 'arguments.searchValue' & chr(35) & '" cfsqltype="cf_sql_varchar" maxlength="#currentSearchFilterSize#" null="false">
					         </cfif>
				         </cfif>
					      order by 1 asc
					   </cfquery>
					   </cfoutput>
				   
				      <cfreturn q>
				      
				   </cffunction>   
			                 '>                          
               
			      <!--- Generate builder fields setters --->
			      <cfset builderFieldsSetters=""> 
			      <cfloop index = "fieldListElement" list = "#viewFields#" delimiters = ",">
					  <cfset fieldListElementUC = #ucase(left(fieldListElement, 1))# & #mid(fieldListElement, 2, len(fieldListElement) -1 )#>
			  		  <cfset builderFieldsSetters=builderFieldsSetters.concat('#chr(13)##chr(10)##chr(9)#.set#removeUnderscore(fieldListElementUC)#(input.get#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member(i).get#removeUnderscore(fieldListElementUC)#())')>
			 	   </cfloop>
               
                          
					<cfset row3 = '
					   <cffunction name="get#ucase(left(listElement,1))##right(listElement,len(listElement)-1)##apiName#BinaryData"
						            output="false"
								      access="remote"
								      returntype="array">
					
						   <cfargument name="filter" type="string" default="">
						 	
							<cflock type="readOnly" timeout="1" name="LockBinCache" throwontimeout="false">
							<cftry>
								<cfset input=' & chr(35) & 'server.cache#ucase(left(listElement,1))##right(listElement,len(listElement)-1)##apiName#Binary' & chr(35) & '>
							<cfcatch type="any">
							</cfcatch>
							</cftry>
							</cflock> 
						 
							<cfscript>		

								paths = arrayNew(1);
							
								paths[1] = expandPath("..\..\..\lib\#apiName#_GoogleProtocolBuffers.jar");
							
								loader = createObject("component", "#apiName#.javaloader.JavaLoader").init(paths);
					
							   #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Protos$#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member");
							   #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Protos$#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection");

						      output = CreateObject("java", "java.io.ByteArrayOutputStream").Init();
						      			
								items= #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Collection.newBuilder();
							   	   		   	   
					         totalItems = input.get#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#MemberCount();
					                  
					         for(i=0;i<totalItems;i++)
								{
									if(input.get#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member(i).get#removeUnderscore(ucase(left(currentSearchFilter,1)))##removeUnderscore(right(currentSearchFilter,len(currentSearchFilter)-1))#() EQ "' & chr(35) & 'filter' & chr(35) & '")
									{	
									
 
					               #lcase(left(listElement,1))##right(listElement,len(listElement)-1)#Member = #ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member.newBuilder() ' & #builderFieldsSetters# & '
						            .build();	   
					      																					
										items.add#ucase(left(listElement,1))##right(listElement,len(listElement)-1)#Member(#lcase(left(listElement,1))##right(listElement,len(listElement)-1)#Member);
										
									}
								}
								items.build().writeTo(output);
								result=output.toByteArray();
					
					         items="";
					
						   </cfscript>
					
					      <cfreturn result>
					   	   
					   </cffunction>
					
					'>                          
                          
				<cfoutput><cfsavecontent variable="dynamicMethodsRow">#row##chr(13)##chr(10)#</cfsavecontent></cfoutput>
				<cfset dynamicMethods=dynamicMethods.concat("#dynamicMethodsRow#")>

				<cfoutput><cfsavecontent variable="dynamicMethodsRow2">#row2##chr(13)##chr(10)#</cfsavecontent></cfoutput>
				<cfset dynamicMethods2=dynamicMethods2.concat("#dynamicMethodsRow2#")>

				<cfoutput><cfsavecontent variable="binaryMethodsRow">#row3##chr(13)##chr(10)#</cfsavecontent></cfoutput>
				<cfset binaryMethods=binaryMethods.concat("#binaryMethodsRow#")>
            <!--- End of Database gateway methods generation block --->
	
		 	
		      <!--- Replace gateway.cfc with dynamicMethods --->
		      <cfset myFile="">
				<cffile file="#tempPath#\data\gateway.cfc" action="read" variable="myFile">
				<cfset result=Replace(#myFile#, "[[*dynamicMethods*]]", "#dynamicMethods#", "all")>
		      <cffile file="#tempPath#\data\#ListElement#Gateway.cfc" action="write" output="#result#">
		
		      <cfset myFile="">
				<cffile file="#tempPath#\data\#ListElement#Gateway.cfc" action="read" variable="myFile">
				<cfset result=Replace(#myFile#, "[[*dynamicMethods2*]]", "#dynamicMethods2#", "all")>
		      <cffile file="#tempPath#\data\#ListElement#Gateway.cfc" action="write" output="#result#">
		
		      <cfset myFile="">
				<cffile file="#tempPath#\data\#ListElement#Gateway.cfc" action="read" variable="myFile">
				<cfset result=Replace(#myFile#, "[[*googleProtocolBufferMethods*]]", "#binaryMethods#", "all")>
		      <cffile file="#tempPath#\data\#ListElement#Gateway.cfc" action="write" output="#result#">
		 	
				<cfset dynamicMethods="">
				<cfset dynamicMethods2="">
				<cfset binaryMethods="">
		 	
         <cfset count = count + 1>
	   </cfloop>
	  
		<!--- Dynamically create the JAR files with Mark Mandell's JavaCompiler.cfc --->
			<cfscript>  	
		
			paths = arrayNew(1);
		
			paths[1] = expandPath("javaloader\lib\tools.jar");
		
			loader = createObject("component", "cfapi.javaloader.JavaLoader").init(paths);
		
			jarDirectory="#tempPath#\..";
			
			compiler = createObject("component", "cfapi.javaloader.JavaCompiler").init(jarDirectory);
				
			sourcepaths = arrayNew(1);
			sourcepaths[1] = "#tempPath#\proto\sources";
			
			jarName="#apiName#_GoogleProtocolBuffers.jar";
										
			compiler.compile(directoryArray=sourcePaths, jarName="#jarName#");			
		
		</cfscript>	  
	  </cfif>
	        
      
      
      
      <cfset binarySearchFunction = '
					   <cffunction name="binarySearch" access="remote" output="false" returntype="string">
					 
						   <cfargument name="myQuery" type="query" required="true"> 
						   <cfargument name="start" type="numeric" required="true">
						   <cfargument name="end" type="numeric" required="true">
						   <cfargument name="searchField" type="string" required="true">
						   <cfargument name="searched" type="string" required="true">
						
						   <cfset i = int((start + end) / 2)>     					
						   <cfset fieldValue = evaluate( " myQuery.' & chr(35) & 'searchField' & chr(35) & '[i]" )>
						   
						   <cfif ' & chr(35) & 'compare(fieldValue, searched)' & chr(35) & ' EQ 0>
						      <cfreturn ' & chr(35) & 'i' & chr(35) & '>
						   <cfelse>
							   <cfif ' & chr(35) & 'start' & chr(35) & ' EQ ' & chr(35) & 'end' & chr(35) & '>
							      <cfreturn "-1">
								<cfelse>
							      <cfif ' & chr(35) & 'compare(fieldValue, searched)' & chr(35) & ' LT 0> 
							         <cfreturn binarySearch(' & chr(35) & 'myQuery' & chr(35) & ', ' & chr(35) & 'i' & chr(35) & ' + 1, ' & chr(35) & 'end' & chr(35) & ', ' & chr(35) & 'searchField' & chr(35) & ', ' & chr(35) & 'searched' & chr(35) & ' )>
							      <cfelse>
							         <cfreturn binarySearch(' & chr(35) & 'myQuery' & chr(35) & ', ' & chr(35) & 'start' & chr(35) & ', ' & chr(35) & 'i' & chr(35) & ' - 1, ' & chr(35) & 'searchField' & chr(35) & ', ' & chr(35) & 'searched' & chr(35) & ' )>
								   </cfif>
							   </cfif>  
						   </cfif>
						   
					   </cffunction>  '>


		<cfoutput><cfsavecontent variable="binarySearchRow">#binarySearchFunction##chr(13)##chr(10)#</cfsavecontent></cfoutput>
		<cfset binaryMethods=binaryMethods.concat("#binarySearchRow#")>

     <cfif #arguments.createCsvSourced# EQ "true">

      <!--- Copy CSV files to temp folder --->
	  	<cfdirectory
		    action="list"
		    directory="#sourcePath#\data\csv\"
		    recurse="true"
		    name="qFile"
			 filter="*.csv"
		    />
		
		<cfoutput query="qFile">							
			<cfif FileExists("#qFile.directory#\#qFile.name#")>
	  	      <cffile action="copy" source="#qFile.directory#\#qFile.name#" destination="#tempPath#\data\csv\#qFile.name#">
			</cfif>
		</cfoutput>
		
      <!--- For each CSV file on the list, create extraction routine --->
      <cfset totalCSV = listLen("#arguments.CSVfileList#", ",")> 
      <cfset CSVcount=1>
      <cfloop index = "ListElement" list = "#arguments.CSVfileList#" delimiters = ",">
	   	   
	      <!--- Extract field list from current CSV file --->
		  	<cfset csvFieldList = getCSVFields("#tempPath#\data\csv\#ListElement#")>
	   
	      <cfset csvFieldList = #deAccent(csvFieldList)#>

         <!--- Extract CSV current search filter --->
		   <cfset CSVcurrentSearchFilter = ListGetAt(#arguments.CSVSearchFilter#, CSVcount, ",")>
	      <cfset CSVcurrentSearchFilterSize = ListGetAt(#arguments.CSVSearchFilterSize#, CSVcount, ",")>
	      <cfset CSVcurrentSearchFilterType = ListGetAt(#arguments.CSVSearchFilterType#, CSVcount, ",")>			      

			<!--- Define feature main query --->
			<cfset dataFetchQuery="select #csvFieldList# from #listElement#">

	      <!--- Check if current CSV file has latitude and longitude fields --->
	      <cfif findNoCase('latitude', "#csvFieldList#") and findNoCase('longitude', "#csvFieldList#")>
	         <cfset foundLatLngForCSV=true>
	      </cfif>

         <!--- Generate builder fields setters --->
	      <cfset builderFieldsSetters=""> 
	      <cfloop index = "fieldListElement" list = "#csvFieldList#" delimiters = ",">
			  <cfset fieldListElementUC = #ucase(left(fieldListElement, 1))# & #mid(fieldListElement, 2, len(fieldListElement) -1 )#>
			    
	  		  <cfset builderFieldsSetters=builderFieldsSetters.concat('#chr(13)##chr(10)##chr(9)#.set#removeUnderscore(fieldListElementUC)#(JavaCast("string", ' & chr(35) & 'dataCache.#fieldListElement#' & chr(35) & ' ))')>
	 	   </cfloop>
	   
	      <cfset row='<cffunction name="fillCache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#" output="false" access="remote" returntype="boolean">

						   <!--- Notes: The maximum CSV file size accepted will depend on your JVM Heap Memory size 
						   	          configured on jvm.config file. If you got memory issues, you will need to change
						   	          some settings. The jvm.config file can be found on your
						   	          cf_root/runtime/bin folder and can be modified in a text editor.
						                To increase heap memory size, locate the section labeled "Arguments to VM",
						                then modify the -Xmx variable to set a maximum heap size, for example: -Xmx1024m.
						                Save the file and restart ColdFusion.   	          
						    --->
							
							<!--- Variable definitions --->
							<cfset var filePath = "">
							<cfset var fields="">
							<cfset var values="">
							<cfset var varchars="">
							<cfset var firstTime=true>
							<cfset var crlf = chr(13) & chr (10)>
							<cfset var dataCache="">
							<cfset var fieldNumber = 1>
							
							<cfset filePath = ExpandPath(".\")>
							<cfloop condition="not ' & chr(35) & 'FileExists(' & chr(39) & chr(35) & 'filePath' & chr(35) & 'application.cfc' & chr(39) & ')' & chr(35) & '">
							   <cfset filePath = "' & chr(35) & 'filePath' & chr(35) & '..\">
							</cfloop>
							<cfset filePath = "' & chr(35) & 'filePath' & chr(35) & 'data\csv\#listElement#">
							
							<!--- Open CSV file for reading --->
							<cffile file="' & chr(35) & 'filePath' & chr(35) & '" action="read" variable="fileIn">
								
							<!--- Iterate through lines --->
							<cfloop list="' & chr(35) & 'fileIn' & chr(35) & '" index="line" delimiters="' & chr(35) & 'crlf' & chr(35) & '">
						
								<cfset fieldNumber = 1>
								
							   <cfif ' & chr(35) & 'firstTime' & chr(35) & ' EQ true>
							  	   <cfset firstTime=false>
							      <cfset fields = deAccent(Replace(line, ";", ",", "all"))>
								   <cfloop index = "ListElement" list = "' & chr(35) & 'fields' & chr(35) & '" delimiters = ",">
								      <cfset varchars=varchars.concat("varchar")>
										<cfif ' & chr(35) & 'ListLast("' & chr(35) & 'fields' & chr(35) & '", ",")' & chr(35) & ' NEQ ' & chr(35) & 'ListElement' & chr(35) & '>
										   <cfset varchars=varchars.concat(",")>
										</cfif>		    
								   </cfloop>
							
							      <!--- Create the memory cache --->
							      <cfset dataCache = QueryNew("' & chr(35) & 'fields' & chr(35) & '", "' & chr(35) & 'varchars' & chr(35) & '")>
							  
							   <cfelse>	
								
								   <cfset values = Replace(line, ";", ",", "all")>
								   <cfset values = Replace(values, ' & chr(39) & chr(34) & chr(39) & ', "", "all")>
								
							      <!--- Convert the CSV to a memory query --->
							
							      <!--- Create a row in memory cache --->
							      <cfset newRow = QueryAddRow(dataCache, 1)>
							      
							      <cfloop index = "fieldName" list = "' & chr(35) & 'fields' & chr(35) & '" delimiters = "," >
							
								      <!--- For each CSV field, copy into the cache, inserting in the created row --->
									
								         <!--- Copy field to the memory cache --->
										   <cfset temp = QuerySetCell("' & chr(35) & 'dataCache' & chr(35) & '", "' & chr(35) & 'fieldName' & chr(35) & '", javacast( "string", ' & chr(35) & 'myGetToken(values, fieldNumber, ",")' & chr(35) & ' ) )>
								   		      
									      <cfif ' & chr(35) & 'fieldNumber' & chr(35) & ' LT ' & chr(35) & 'listLen(' & chr(35) & 'fields' & chr(35) & ')' & chr(35) & '>
									         <cfset fieldNumber = fieldNumber + 1>
										   </cfif>  	   		      
							      </cfloop>
								      		   
								</cfif>
						
								</cfloop>
							
						      <!--- Move data from temp area to real server cache --->
						
						      <!--- Here we have to lock the code --->
						      <cflock type="exclusive" timeout="10" name="LockCache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#" throwontimeout="false">
						         <cftry>
						            <!--- Recreate the data cache --->
						            <cfset server.cache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName# = ' & chr(35) & 'dataCache' & chr(35) & '>
						         <cfcatch type="any">
						         </cfcatch>	 
						         </cftry>
						 	   </cflock>
						      
						      <!--- Create in memory a binary collection for Google Protocol Buffers consuming --->
								<cfscript>
										
							
									paths = arrayNew(1);
								
									// Define the JARs involved.
									paths[1] = expandPath("lib\#apiName#_GoogleProtocolBuffers.jar");
								
									// Javaloader is needed to get the required JARs without changing Coldfusion Administrator classpath.
									loader = createObject("component", "#apiName#.javaloader.JavaLoader").init(paths);
																
								   // Create the required class instances to build the binary cache.
								   #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Protos$#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member");
								   #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Protos$#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection");
								   
							      #lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection = #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection.newBuilder();
								   					   	 		
								</cfscript>
							
								<!--- Iterate over the query cache, generating items to fill the binary cache --->
								<cfloop query="dataCache">
								
									<cfscript>
										
										// Create a new object.
								      #lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member = #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member.newBuilder() ' & #builderFieldsSetters# & '
									   .build();	   
								      
								      // Add the object to collection.
								      #lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection.add#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member(#lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member);
									</cfscript>
								
								</cfloop>
											
						      <!--- Copy the created collection to the real binary cache --->
						      <cflock type="exclusive" timeout="5" name="LockBinCache" throwontimeout="false">
						         <cftry>
						            <cfset server.cache#lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Binary = ' & chr(35) & '#lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection' & chr(35) & '>
						         <cfcatch type="any">
						         </cfcatch>	 
						         </cftry>
							   </cflock>     
						           
						      <!--- Empty temp variables --->
						      <cfset cacheForBinary="">
						      <cfset dataCache="">
						      <cfset #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member = "">
						      <cfset #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection = "">
						      <cfset loader=""> 
						
							   <!--- Return --->
							   <cfreturn true>
						      
						   </cffunction>
							
                        '>

            <cfset row2 = '
				   <cffunction name="getDataFromCache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#"
					 		      returntype="query"
							      hint="Gets data from memory cache."
							      access="public"
							      output="false">      
				
				      <!--- List of arguments --->
					   <cfargument name="searchValue" type="string" required="false">
					      
						<!--- Variables declarations ---> 
				      <cfset var q = "">
				      <cfset var tempQuery = QueryNew("#csvFieldList#")>
				      <cfset searchValue = lcase(searchValue)>
					
				      <cflock type="readOnly" timeout="1" name="LockCache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#" throwontimeout="false">
					     <cftry>
						    <cfset tempQuery=server.cache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#>
					     <cfcatch>
						  </cfcatch>
						  </cftry>
				 	   </cflock>     	
				
					   <cfoutput>
					   <cfquery dbtype="query" name="q" timeout="10">
					      select #csvFieldList#
						   from tempQuery
					      <cfif len(' & chr(35) & 'arguments.searchValue' & chr(35) & ') GT 0>
					         <cfif "#CSVcurrentSearchFilterType#" EQ "numeric">     
					            where CAST("#CSVcurrentSearchFilter#" as DOUBLE) = CAST(<cfqueryparam value="' & chr(35) & 'arguments.searchValue' & chr(35) & '" cfsqltype="cf_sql_varchar" maxlength="#CSVcurrentSearchFilterSize#" null="false"> as DOUBLE)
						      </cfif>
				            <cfif "#CSVcurrentSearchFilter#" EQ "string">
				               where lower(#CSVcurrentSearchFilter#) = <cfqueryparam value="' & chr(35) & 'arguments.searchValue' & chr(35) & '" cfsqltype="cf_sql_varchar" maxlength="#CSVcurrentSearchFilterSize#" null="false">
					         </cfif>
				         </cfif>
					      order by 1 asc
					   </cfquery>
					   </cfoutput>
				   
				      <cfreturn q>
				      
				   </cffunction>   
			                 '>                          


					<cfset row3 = '
					   <cffunction name="get#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#BinaryData"
						            output="false"
								      access="remote"
								      returntype="array">
					
						   <cfargument name="filter" type="string" default="">
						 	
							<cflock type="readOnly" timeout="1" name="LockBinCache" throwontimeout="false">
							<cftry>
								<cfset input=' & chr(35) & 'server.cache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Binary' & chr(35) & '>
							<cfcatch type="any">
							</cfcatch>
							</cftry>
							</cflock> 
						 
							<cfscript>		

								paths = arrayNew(1);
							
								paths[1] = expandPath("..\..\..\lib\#apiName#_GoogleProtocolBuffers.jar");
							
								loader = createObject("component", "#apiName#.javaloader.JavaLoader").init(paths);
					
							   #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Protos$#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member");
							   #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Protos$#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection");

						      output = CreateObject("java", "java.io.ByteArrayOutputStream").Init();
						      			
								items= #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection.newBuilder();
							   	   		   	   
					         totalItems = input.get#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#MemberCount();
					                  
					         for(i=0;i<totalItems;i++)
								{
									if(input.get#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member(i).get#removeUnderscore(ucase(left(CSVcurrentSearchFilter,1)))##removeUnderscore(right(CSVcurrentSearchFilter,len(CSVcurrentSearchFilter)-1))#() EQ "' & chr(35) & 'filter' & chr(35) & '")
									{	
									
 
					               #lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member = #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member.newBuilder() ' & #builderFieldsSetters# & '
						            .build();	   
					      																					
										items.add#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member(#lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member);
										
									}
								}
								items.build().writeTo(output);
								result=output.toByteArray();
					
					         items="";
					
						   </cfscript>
					
					      <cfreturn result>
					   	   
					   </cffunction>
					
					'>                          


				<cfoutput><cfsavecontent variable="CSVMethodsRow">#row##chr(13)##chr(10)##row2##chr(13)##chr(10)##row3##chr(13)##chr(10)#</cfsavecontent></cfoutput>
				<cfset CSVMethods=CSVMethods.concat("#CSVMethodsRow#")>
	   
            <!--- Generate dynamically memory cache definitions for CSV files datasources --->
				<cfset row='
				   <cftry>
				 	   <!--- Verify if cache is already defined, otherwhise define it --->  
					      <!--- Set up fields of the cached query, as fetched from first line of CSV file ---> 
					      <cfset q = QueryNew("#csvFieldList#")>
				  		   <cfparam name="server.cache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#" type="query" default="' & chr(35) & 'q' & chr(35) & '">
					<cfcatch type="any">
					</cfcatch>
					</cftry>'>
					
				<cfoutput><cfsavecontent variable="dynamicCacheDefinitionCSVRow">#row##chr(13)##chr(10)#</cfsavecontent></cfoutput>
				<cfset dynamicDefinitionsForCSV=dynamicDefinitionsForCSV.concat("#dynamicCacheDefinitionCSVRow#")>
	
	         <!--- Generate dynamically memory cache definitions --->
				<cfset row='
					<!--- Creates a memory cache for binary data --->
				   <cftry>  	
							<cfscript>	
								
								paths = arrayNew(1);
							
								paths[1] = expandPath("lib\#apiName#_GoogleProtocolBuffers.jar");
							
								loader = createObject("component", "#apiName#.javaloader.JavaLoader").init(paths);
									
							   #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Protos$#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member");
							   #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection = loader.create("com.#arguments.apiName#.protos.#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Protos$#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection");
							   		   
								#lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection = #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection.newBuilder();
															
							   server.cache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Binary = #lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection;
							</cfscript>
					<cfcatch type="any">
					</cfcatch>
					</cftry>'>
					
				<cfoutput><cfsavecontent variable="binaryCacheDefinitionRow">#row##chr(13)##chr(10)#</cfsavecontent></cfoutput>
				<cfset binaryCacheDefinitions=binaryCacheDefinitions.concat("#binaryCacheDefinitionRow#")>
	
	         <!--- Generate dynamic invokes for index.cfm and updateCache.cfm files --->
				<cfset row='<cfinvoke component="#arguments.apiName#.data.#replaceNoCase(ListElement,'.csv','','all')#Gateway" method="fillCache#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#" returnvariable="result">'>
				<cfoutput><cfsavecontent variable="dynamicInvokesForCSVRow">#row##chr(13)##chr(10)#</cfsavecontent></cfoutput>
	         <cfset dynamicInvokesForCSV=dynamicInvokesForCSV.concat("#dynamicInvokesForCSVRow#")>       

		      <!--- Create one "items" file for each csv file, and for each format --->
		      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\csv\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\csv\#mid(listElement,1,len(listElement)-4)#.cfm">
						<cffile file="#tempPath#\api\#arguments.apiVersion#\csv\#mid(listElement,1,len(listElement)-4)#.cfm" action="read" variable="myFile1">
						<cfset result=Replace(#myFile1#, "[[*apiName*]]", "#arguments.apiName#", "all")>
		            <cfset result=Replace(#result#, "[[*viewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
				      <cfset result=Replace(#result#, "[[*viewFields*]]", "#csvFieldList#", "all")>
					   <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilter*]]", "#CSVcurrentSearchFilter#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#CSVcurrentSearchFilterType#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#CSVcurrentSearchFilterSize#", "all")>				      				      
				      <cffile file="#tempPath#\api\#arguments.apiVersion#\csv\#mid(listElement,1,len(listElement)-4)#.cfm" action="write" output="#result#" nameconflict="overwrite">
	
		      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\rest\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\rest\#mid(listElement,1,len(listElement)-4)#.cfm">
						<cffile file="#tempPath#\api\#arguments.apiVersion#\rest\#mid(listElement,1,len(listElement)-4)#.cfm" action="read" variable="myFile2">
						<cfset result=Replace(#myFile2#, "[[*apiName*]]", "#arguments.apiName#", "all")>
		            <cfset result=Replace(#result#, "[[*viewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
				      <cfset result=Replace(#result#, "[[*viewFields*]]", "#csvFieldList#", "all")>
					   <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilter*]]", "#CSVcurrentSearchFilter#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#CSVcurrentSearchFilterType#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#CSVcurrentSearchFilterSize#", "all")>				    
				      <cffile file="#tempPath#\api\#arguments.apiVersion#\rest\#mid(listElement,1,len(listElement)-4)#.cfm" action="write" output="#result#" nameconflict="overwrite">
	               
			   <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\soap\WSItems.cfc" destination="#tempPath#\api\#arguments.apiVersion#\soap\WS#mid(listElement,1,len(listElement)-4)#.cfc">
						<cffile file="#tempPath#\api\#arguments.apiVersion#\soap\WS#mid(listElement,1,len(listElement)-4)#.cfc" action="read" variable="myFile3">
						<cfset result=Replace(#myFile3#, "[[*apiName*]]", "#arguments.apiName#", "all")>
		            <cfset result=Replace(#result#, "[[*viewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
				      <cfset result=Replace(#result#, "[[*viewFields*]]", "#csvFieldList#", "all")>
					   <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilter*]]", "#CSVcurrentSearchFilter#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#CSVcurrentSearchFilterType#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#CSVcurrentSearchFilterSize#", "all")>				    
				      <cffile file="#tempPath#\api\#arguments.apiVersion#\soap\WS#mid(listElement,1,len(listElement)-4)#.cfc" action="write" output="#result#" nameconflict="overwrite">
	
		      <!--- If current view/table has latitude and longitude fields, then the generated API will provide KML and GeoJSON output  --->
		      <cfif #foundLatLngForCSV#>
			      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\kml\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\kml\#mid(listElement,1,len(listElement)-4)#.cfm">
							<cffile file="#tempPath#\api\#arguments.apiVersion#\kml\#mid(listElement,1,len(listElement)-4)#.cfm" action="read" variable="myFile4">
							<cfset result=Replace(#myFile4#, "[[*apiName*]]", "#arguments.apiName#", "all")>
			            <cfset result=Replace(#result#, "[[*viewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
					      <cfset result=Replace(#result#, "[[*viewFields*]]", "#csvFieldList#", "all")>
						   <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
							<cfset result=Replace(#result#, "[[*searchFilter*]]", "#CSVcurrentSearchFilter#", "all")>
							<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#CSVcurrentSearchFilterType#", "all")>
							<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#CSVcurrentSearchFilterSize#", "all")>
							<cfset result=Replace(#result#, "[[*nameFieldForKml*]]", "#CSVcurrentSearchFilter#", "all")>
					      <cffile file="#tempPath#\api\#arguments.apiVersion#\kml\#mid(listElement,1,len(listElement)-4)#.cfm" action="write" output="#result#" nameconflict="overwrite">
			            <cfset #application.kmlFiles# = #application.kmlFiles# & "#mid(listElement,1,len(listElement)-4)#">
						   <cfif #listElement# NEQ listlast(#viewName#, ",")>
						      <cfset #application.kmlFiles# = #application.kmlFiles# & ",">
						   </cfif>
	
			      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\GeoJSON\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\GeoJSON\#mid(listElement,1,len(listElement)-4)#.cfm">
							<cffile file="#tempPath#\api\#arguments.apiVersion#\GeoJSON\#mid(listElement,1,len(listElement)-4)#.cfm" action="read" variable="myFile5">
							<cfset result=Replace(#myFile5#, "[[*apiName*]]", "#arguments.apiName#", "all")>
			            <cfset result=Replace(#result#, "[[*viewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
					      <cfset result=Replace(#result#, "[[*viewFields*]]", "#csvFieldList#", "all")>
						   <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
							<cfset result=Replace(#result#, "[[*searchFilter*]]", "#CSVcurrentSearchFilter#", "all")>
							<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#CSVcurrentSearchFilterType#", "all")>
							<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#CSVcurrentSearchFilterSize#", "all")>
							<cfset result=Replace(#result#, "[[*nameFieldForKml*]]", "#CSVcurrentSearchFilter#", "all")>
					      <cffile file="#tempPath#\api\#arguments.apiVersion#\GeoJSON\#mid(listElement,1,len(listElement)-4)#.cfm" action="write" output="#result#" nameconflict="overwrite">
			            <cfset #application.geoFiles# = #application.geoFiles# & "#mid(listElement,1,len(listElement)-4)#">
						   <cfif #listElement# NEQ listlast(#viewName#, ",")>
						      <cfset #application.geoFiles# = #application.geoFiles# & ",">
						   </cfif>
			   
			   </cfif>
	
	         <!--- Create the XML files --->
		      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\xml\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\xml\#mid(listElement,1,len(listElement)-4)#.cfm">
						<cffile file="#tempPath#\api\#arguments.apiVersion#\xml\#mid(listElement,1,len(listElement)-4)#.cfm" action="read" variable="myFile6">
						<cfset result=Replace(#myFile6#, "[[*apiName*]]", "#arguments.apiName#", "all")>
		            <cfset result=Replace(#result#, "[[*viewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
				      <cfset result=Replace(#result#, "[[*viewFields*]]", "#csvFieldList#", "all")>
					   <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilter*]]", "#CSVcurrentSearchFilter#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#CSVcurrentSearchFilterType#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#CSVcurrentSearchFilterSize#", "all")>				    
				      <cffile file="#tempPath#\api\#arguments.apiVersion#\xml\#mid(listElement,1,len(listElement)-4)#.cfm" action="write" output="#result#" nameconflict="overwrite">
	

	         <!--- Create Google Protocol Buffers Binary files --->
		      <cffile action="copy" source="#tempPath#\api\#arguments.apiVersion#\binary\items.cfm" destination="#tempPath#\api\#arguments.apiVersion#\binary\#mid(listElement,1,len(listElement)-4)#.cfm">
						<cffile file="#tempPath#\api\#arguments.apiVersion#\binary\#mid(listElement,1,len(listElement)-4)#.cfm" action="read" variable="myFile7">
						<cfset result=Replace(#myFile7#, "[[*apiName*]]", "#arguments.apiName#", "all")>
		            <cfset result=Replace(#result#, "[[*viewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
				      <cfset result=Replace(#result#, "[[*viewFields*]]", "#csvFieldList#", "all")>
					   <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#mid(listElement,1,len(listElement)-4)#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilter*]]", "#CSVcurrentSearchFilter#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterType*]]", "#CSVcurrentSearchFilterType#", "all")>
						<cfset result=Replace(#result#, "[[*searchFilterSize*]]", "#CSVcurrentSearchFilterSize#", "all")>				    
				      <cffile file="#tempPath#\api\#arguments.apiVersion#\binary\#mid(listElement,1,len(listElement)-4)#.cfm" action="write" output="#result#" nameconflict="overwrite">
	            
				<!--- Create the DTOs --->
				<cfset oldLocale=setLocale("en")>
				<cfset header='<cfcomponent displayname="#mid(listElement,1,len(listElement)-4)#DTO" hint="#mid(listElement,1,len(listElement)-4)# Class">#chr(13)##chr(10)#'>
				<cfset footer="</cfcomponent>">
				<cfset filename="#tempPath#\DTO\#mid(listElement,1,len(listElement)-4)#.cfc">   
				
				<cffile action="write" file="#filename#" output="#header#">
				
				<cfsavecontent variable="DTOFileContent"><cfloop index = "fieldListElement" list = "#csvFieldList#" delimiters = ","><cfset row='   <cfproperty name="#fieldListElement#" type="string">#chr(13)##chr(10)#'><cfoutput>#row#</cfoutput></cfloop></cfsavecontent>
				<cffile file="#filename#" action="append" output="#DTOFileContent#">
				<cffile file="#filename#" action="append" output="#footer#">
				<!--- End of block --->


				<!--- Create the .PROTO files (for Google Protocol Buffers binary endpoints) --->
				<cfset oldLocale=setLocale("en")>
				<cfset header="package #arguments.apiName#;#chr(13)##chr(10)#">
				<cfset optJavaPackage='option java_package = "com.#arguments.apiName#.protos";#chr(13)##chr(10)#'>
				<cfset optJavaOuterClassName='option java_outer_classname = "#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Protos" ;#chr(13)##chr(10)#'>
				<cfset filename="#tempPath#\proto\#mid(listElement,1,len(listElement)-4)#.proto">
				
				<cffile action="write" file="#filename#" output="#header#">
				<cffile action="append" file="#filename#" output="#optJavaPackage#">
				<cffile action="append" file="#filename#" output="#optJavaOuterClassName#">
				
				<cfsavecontent variable="protoFileContent">message <cfoutput>#ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member#chr(13)##chr(10)#{#chr(13)##chr(10)#</cfoutput><cfset i = 1><cfloop index = "fieldListElement" list = "#csvFieldList#" delimiters = ","><cfset row='   required string #fieldListElement# = #i#;#chr(13)##chr(10)#'><cfset i = i + 1><cfoutput>#row#</cfoutput></cfloop>}</cfsavecontent>
				<cffile file="#filename#" action="append" output="#protoFileContent#">
				
				<cfsavecontent variable="protoFileContent"><cfoutput>#chr(13)##chr(10)#message #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Collection#chr(13)##chr(10)#{#chr(13)##chr(10)#</cfoutput><cfset i = 1><cfset row='   repeated #ucase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member #lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)##apiName#Member = 1;#chr(13)##chr(10)#'><cfoutput>#row#</cfoutput>}</cfsavecontent>
				<cffile file="#filename#" action="append" output="#protoFileContent#">			
				<!--- End of block --->
		
	         <!--- Compile the .PROTO files for Google Protocol Buffers (Windows executable. Get protoc for Linux if it is your Operating System). --->
		 	   <cfexecute name="#tempPath#\proto\protoc.exe" arguments="--java_out #tempPath#\proto\sources --proto_path #tempPath#\proto #tempPath#\proto\#lcase(left(listElement,1))##mid(listElement,2,len(listElement)-5)#.proto" />


		      <!--- Replace gateway.cfc with dynamicMethods --->
		      <cfset myFile="">
			   <cfset gatewayFileName=#replaceNocase(listElement, ".csv", "", "all")#>
				<cffile file="#tempPath#\data\gateway.cfc" action="read" variable="myFile">
				<cfset result=Replace(#myFile#, "[[*dynamicMethods*]]", "#dynamicMethods#", "all")>
		      <cffile file="#tempPath#\data\#gatewayFileName#Gateway.cfc" action="write" output="#result#">
		
		      <cfset myFile="">
				<cffile file="#tempPath#\data\#gatewayFileName#Gateway.cfc" action="read" variable="myFile">
				<cfset result=Replace(#myFile#, "[[*dynamicMethods2*]]", "#dynamicMethods2#", "all")>
		      <cffile file="#tempPath#\data\#gatewayFileName#Gateway.cfc" action="write" output="#result#">
		
		      <cfset myFile="">
				<cffile file="#tempPath#\data\#gatewayFileName#Gateway.cfc" action="read" variable="myFile">
				<cfset result=Replace(#myFile#, "[[*googleProtocolBufferMethods*]]", "#binaryMethods#", "all")>
		      <cffile file="#tempPath#\data\#gatewayFileName#Gateway.cfc" action="write" output="#result#">

		      <!--- CSV file as datasource Methods --->
		      <cfset deAccentRow = '
									<cffunction name="deAccent" access="remote" returntype="string"> 
									
										<cfargument name="str" type="string" required="true">
										
										<cfset var deAccented="">
										
									    <cfscript>
											 Normalizer = createObject("java","java.text.Normalizer");
										    NormalizerForm = createObject("java","java.text.Normalizer$Form");
										    normalizedString = Normalizer.normalize(str, createObject("java","java.text.Normalizer$Form").NFD);
										    pattern = createObject("java","java.util.regex.Pattern").compile("\p{InCombiningDiacriticalMarks}+");
										    	    
										    deAccented = pattern.matcher(normalizedString).replaceAll("");
										    
									    </cfscript>
									
									    <cfreturn deAccented>
									
									</cffunction>			
			                 '>
			  	
			  	<cfset myGetTokenRow = '
												<cffunction name="myGetToken" access="remote" returntype="string">
												   <cfargument name="str" type="string" required="true">	
												   <cfargument name="index" type="string" required="true">
												   <cfargument name="delimiter" type="string" required="false" default=",">
												    
												   <cfset var result="">   
												   <cfset var readChar="">
												   <cfset var startPosition=1>
												   <cfset var endPosition=0>
												   <cfset var delimiterCount=0>
												         
												   <cftry>	   	   
													   <cfloop from="1" to="' & chr(35) & 'len(trim(str))' & chr(35) & '" index="i">
													      <cfset readChar = mid(trim(str), ' & chr(35) & 'i' & chr(35) & ', 1) >
													            
													      <cfif ' & chr(35) & 'readChar' & chr(35) & ' EQ ' & chr(35) & 'delimiter' & chr(35) & '>
														  	   <cfset startPosition = endPosition + 1>
														  	   <cfset endPosition = ' & chr(35) & 'i' & chr(35) & '>
														      <cfset delimiterCount = delimiterCount + 1>
														   </cfif>
														   	   
														   <cfif ' & chr(35) & 'delimiterCount' & chr(35) & ' EQ ' & chr(35) & 'index' & chr(35) & '> 
													         <cfset result = mid(str, startPosition, (endPosition - startPosition))>
														      <cfbreak>
														   </cfif>	   
													   </cfloop>
															
													   <cfif ' & chr(35) & 'index' & chr(35) & ' GT ' & chr(35) & 'delimiterCount' & chr(35) & ' and (' & chr(35) & 'index' & chr(35) & ' - ' & chr(35) & 'delimiterCount' & chr(35) & ' EQ 1) >
													   	<cfset startPosition = endPosition + 1>   
													      <cfset result = mid(str, startPosition, len(str) - endPosition)>
													   </cfif> 
												
												   <cfcatch>
												      <cfset result="">
												   </cfcatch>
												   </cftry>
												
												   <cfreturn result>
												</cffunction>
		
		                      		  '>
			  	
		      <cfset myFile="">
				<cffile file="#tempPath#\data\#gatewayFileName#Gateway.cfc" action="read" variable="myFile">
				<cfset result=Replace(#myFile#, "[[*dynamicMethodsForCsvFiles*]]", "#CSVMethods#", "one")>
				<cfset result=Replace(#result#, "[[*deAccent*]]", "#deAccentRow#", "one" )>
				<cfset result=Replace(#result#, "[[*myGetToken*]]", "#myGetTokenRow#", "one" )>
		      <cffile file="#tempPath#\data\#gatewayFileName#Gateway.cfc" action="write" output="#result#">

				<cfset dynamicMethods="">
				<cfset dynamicMethods2="">
				<cfset binaryMethods="">

            <cfset CSVcount = CSVcount + 1>

	   </cfloop>

      <!--- Replace application.cfc with dynamicCacheDefinitions --->
      <cfset myFile="">
		<cffile file="#tempPath#\application.cfc" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*memoryCacheDefinitionsForCSV*]]", "#dynamicDefinitionsForCSV#", "all")>
      <cffile file="#tempPath#\application.cfc" action="write" output="#result#">

		<!--- Dynamically create the JAR files with Mark Mandell's JavaCompiler.cfc --->
		<cfscript>  	
		
			paths = arrayNew(1);
			
			paths[1] = expandPath("javaloader\lib\tools.jar");
			
			loader = createObject("component", "cfapi.javaloader.JavaLoader").init(paths);
			
			jarDirectory="#tempPath#\..";
			
			compiler = createObject("component", "cfapi.javaloader.JavaCompiler").init(jarDirectory);
				
			sourcepaths = arrayNew(1);
			sourcepaths[1] = "#tempPath#\proto\sources";
			
			jarName="#apiName#_GoogleProtocolBuffers.jar";
										
			compiler.compile(directoryArray=sourcePaths, jarName="#jarName#");			
		
		</cfscript>

	   </cfif>


		<!--- Replace markups in every file --->
		<cfdirectory
		    action="list"
		    directory="#tempPath#"
		    recurse="true"
		    name="qFile"
		    />
		
		<cfoutput query="qFile">							
			<cfif FileExists("#qFile.directory#\#qFile.name#")>
		
				<cffile file="#qFile.directory#\#qFile.name#" action="read" variable="myFile">
				<cfset result=Replace(#myFile#, "[[*apiName*]]", "#arguments.apiName#", "all")>
				<cfset result=Replace(#result#, "[[*apiVersion*]]", "#arguments.apiVersion#", "all")>
				<cfset result=Replace(#result#, "[[*dataSourceName*]]", "#arguments.dataSourceName#", "all")>
				<cfset result=Replace(#result#, "[[*accessToken*]]", "#arguments.accessToken#", "all")>
				<cfset result=Replace(#result#, "[[*featureDescription*]]", "Gets all data from view", "all")>
				<cfset result=Replace(#result#, "[[*dataFetchQuery*]]", "#dataFetchQuery#", "all")>
				<cfset result=Replace(#result#, "[[*daysInCache*]]", "#arguments.daysInCache#", "all")>
				<cfset result=Replace(#result#, "[[*hoursInCache*]]","#arguments.hoursInCache#", "all")>
				<cfset result=Replace(#result#, "[[*minutesInCache*]]", "#arguments.minutesInCache#", "all")>
				<cfset result=Replace(#result#, "[[*secondsInCache*]]", "#arguments.secondsInCache#", "all")>
            <cfset result=Replace(#result#, "[[*totalViews*]]", "#totalViews#", "all")>
			   <cfset result=Replace(#result#, "[[*totalDatasources*]]", #totalViews# + #totalCSV#, "all")>
			   
			   <!--- Compose list of datasources, according to user´s choices --->
			   <cfset dataSourceNamesList = "">
			   <cfif #arguments.createDatabaseSourced# EQ "true" and #totalViews# GT 0>
			      <cfset dataSourceNamesList = "#viewName#">
			   </cfif>
			   <cfif #arguments.createCsvSourced# EQ "true" and #totalCSV# GT 0>
			   	<cfif #arguments.createDatabaseSourced# EQ "true" and #totalViews# GT 0>
                  <cfset dataSourceNamesList = dataSourceNamesList & ",">
               </cfif>
               
			      <cfset dataSourceNamesList = dataSourceNamesList & "#replace(arguments.CSVfileList, ".csv", "", "all")#">
			   </cfif>			   
			   	
			   <cfset result=Replace(#result#, "[[*dataSourceNames*]]", "#dataSourceNamesList#", "all")>

            <!--- Prepare dynamically Android Client, if required ---> 
            <cfif #arguments.createAndroidClient# EQ "true">
		  	      <!--- Create two versions of the variable, one to refer to a Java Class, the other one to refer to a Java Object --->
				   <cfset viewForAndroidUC = #ucase(left(arguments.viewForAndroid, 1))# & #lcase(mid(arguments.viewForAndroid, 2, len(arguments.viewForAndroid) -1 ))#>  	
               <cfset viewForAndroidLC = #lcase(arguments.viewForAndroid)#>
               <cfset searchFilterUC = #ucase(left(arguments.searchFilter, 1))# & #lcase(mid(arguments.searchFilter, 2, len(arguments.searchFilter) -1 ))#>

               <!--- Replace terms in Android source files --->
               <cfset result=Replace(#result#, "[[*viewNameUC*]]", "#viewForAndroidUC#", "all")>
			      <cfset result=Replace(#result#, "[[*viewNameLC*]]", "#viewForAndroidLC#", "all")>
               <cfset result=Replace(#result#, "[[*endPointDomain*]]", "#arguments.endPointDomain#", "all")>
               <cfset result=Replace(#result#, "[[*initialMapLatitude*]]", "#arguments.initialMapLatitude#", "all")>
               <cfset result=Replace(#result#, "[[*initialMapLongitude*]]", "#arguments.initialMapLongitude#", "all")>				  		     
               <cfset result=Replace(#result#, "[[*pluralViewName*]]", "#arguments.pluralViewName#", "all")>
			      <cfset result=Replace(#result#, "[[*searchFilterUC*]]", "#searchFilterUC#", "all")>
		      </cfif>
								 
			   <!--- Save the changed file --->
			   <cffile file="#qFile.directory#\#qFile.name#" action="write" output="#result#" nameconflict="overwrite">
         </cfif>
		</cfoutput> 
		<!--- End of markup replace block --->

      <cfif #arguments.createAndroidClient# EQ "true">
      <!--- Generates dynamic fetch instructions of Android APP webService consumer --->
		<!--- Extract Android view fields, dynamically --->
		<cfdbinfo  
		    type="Columns" table="#viewForAndroidLC#" 
		    datasource="#dataSourceName#" 
		    name="dbdata">
			
		<cfset fields="">
		
		<cfquery dbtype="query" name="getDistinctFields">
			select distinct column_name from dbdata
		</cfquery>
			
		<cfoutput query="getDistinctFields">
			<cfset fieldName = "#getDistinctFields.column_name#">
			<cfset fields=fields.concat(#fieldName#)>
		   <cfif #getDistinctFields.currentRow# NEQ #getDistinctFields.recordcount#>
		      <cfset fields=fields.concat(",")>
		   </cfif>
		</cfoutput>	
		
		<cfset viewFieldsForAndroid="#deAccent(fields)#">
		<!--- End of extract fields dynamically --->

      <!--- Extractors --->
      <cfset row="">
      <cfloop index = "fieldListElement" list = "#viewFieldsForAndroid#" delimiters = ",">
	  		  <cfset row=row.concat('#chr(9)##chr(9)#String #lcase(fieldListElement)#=oneObject.getString("#ucase(fieldListElement)#");#chr(13)##chr(10)#')>
 	   </cfloop>

      <cfset myFile="">
		<cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\ws\ItemWS.java" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*jsonFetchForAppWS*]]", "#row#", "all")>
      <cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\ws\ItemWS.java" action="write" output="#result#">

      <!--- Setters --->
      <cfset row="">
      <cfloop index = "fieldListElement" list = "#viewFieldsForAndroid#" delimiters = ",">
	  	     <cfset fieldListElementUC = #ucase(left(fieldListElement, 1))# & #mid(fieldListElement, 2, len(fieldListElement) -1 )#>
	  		  <cfset row=row.concat('#chr(9)##chr(9)# #viewForAndroidLC#.set#fieldListElementUC#(#fieldListElement#); #chr(13)##chr(10)#')>
 	   </cfloop>

      <cfset myFile="">
		<cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\ws\ItemWS.java" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*jsonSettersforAppWS*]]", "#row#", "all")>
      <cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\ws\ItemWS.java" action="write" output="#result#">            

      <!--- Android DTOs --->
      <cfset row="">
      <cfloop index = "fieldListElement" list = "#viewFieldsForAndroid#" delimiters = ",">
	  		  <cfset row=row.concat('#chr(9)#String #lcase(fieldListElement)#="";#chr(13)##chr(10)#')>
 	   </cfloop>

      <cfset myFile="">
		<cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\dto\ItemDTO.java" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*dtoVariablesDeclaration*]]", "#row#", "all")>
      <cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\dto\ItemDTO.java" action="write" output="#result#">

      <!--- Android DTO getters --->
      <cfset row="">
      <cfloop index = "fieldListElement" list = "#viewFieldsForAndroid#" delimiters = ",">
	  	     <cfset fieldListElementUC = #ucase(left(fieldListElement, 1))# & #mid(fieldListElement, 2, len(fieldListElement) -1 )#>
			  <cfset fieldListElementLC = #lcase(left(fieldListElement, 1))# & #mid(fieldListElement, 2, len(fieldListElement) -1 )#>
	  		  <cfset row=row.concat('#chr(9)#public String get#fieldListElementUC#()#chr(13)##chr(10)##chr(9)#{#chr(13)##chr(10)##chr(9)#   return #fieldListElementLC#;#chr(13)##chr(10)##chr(9)#}#chr(13)##chr(10)#')>
 	   </cfloop>

      <cfset myFile="">
		<cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\dto\ItemDTO.java" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*dtoGetters*]]", "#row#", "all")>
      <cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\dto\ItemDTO.java" action="write" output="#result#">            
	  	
	  	<!--- Android DTO setters --->	  	
      <cfset row="">
      <cfloop index = "fieldListElement" list = "#viewFieldsForAndroid#" delimiters = ",">
	  	     <cfset fieldListElementUC = #ucase(left(fieldListElement, 1))# & #mid(fieldListElement, 2, len(fieldListElement) -1 )#>
			  <cfset fieldListElementLC = #lcase(left(fieldListElement, 1))# & #mid(fieldListElement, 2, len(fieldListElement) -1 )#>
	  		  <cfset row=row.concat('#chr(9)#public void set#fieldListElementUC#(String #fieldListElementLC#)#chr(13)##chr(10)##chr(9)#{#chr(13)##chr(10)##chr(9)#   this.#fieldListElementLC#=#fieldListElementLC#;#chr(13)##chr(10)##chr(9)#}#chr(13)##chr(10)#')>
 	   </cfloop>

      <cfset myFile="">
		<cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\dto\ItemDTO.java" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*dtoSetters*]]", "#row#", "all")>
      <cffile file="#tempPath#\clients\android\src\com\cfapi\apiName\dto\ItemDTO.java" action="write" output="#result#">            

      <!--- Rename item files for Android app --->
      <cffile action="rename" destination="#viewForAndroidUC#WS.java" source="#tempPath#\clients\android\src\com\cfapi\apiName\ws\ItemWS.java">
      <cffile action="rename" destination="#viewForAndroidUC#DTO.java" source="#tempPath#\clients\android\src\com\cfapi\apiName\dto\ItemDTO.java">

      <!--- Rename apiName folder for Android app --->
	  	<cfdirectory action="rename" directory="#tempPath#\clients\android\src\com\cfapi\apiName" newdirectory="#tempPath#\clients\android\src\com\cfapi\#arguments.apiName#">
	   </cfif>
	  
      <!--- Replace index.cfm and updateCache.cfm with dynamicInvokes --->
      <cfset myFile="">
		<cffile file="#tempPath#\index.cfm" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*updateCacheInvokes*]]", "#dynamicInvokes#", "all")>
		<cfset result=Replace(#result#, "[[*updateCacheInvokesForCSV*]]", "#dynamicInvokesForCSV#", "all")>
		<cfset result=Replace(#result#, "[[*apiName*]]", "#arguments.apiName#", "all")>
		<cfset result=Replace(#result#, "[[*apiVersion*]]", "#arguments.apiVersion#", "all")>
		<cfset result=Replace(#result#, "[[*pluralViewName*]]", "#arguments.pluralViewName#", "all")>
      <cffile file="#tempPath#\index.cfm" action="write" output="#result#">
      <cfset myFile="">
		<cffile file="#tempPath#\ScheduledTasks\updateCache.cfm" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*updateCacheInvokes*]]", "#dynamicInvokes#", "all")>
		<cfset result=Replace(#result#, "[[*updateCacheInvokesForCSV*]]", "#dynamicInvokesForCSV#", "all")>
      <cffile file="#tempPath#\ScheduledTasks\updateCache.cfm" action="write" output="#result#">


      <!--- Replace application.cfc with dynamicCacheDefinitions --->
      <cfset myFile="">
		<cffile file="#tempPath#\application.cfc" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*memoryCacheDefinitions*]]", "#dynamicDefinitions#", "all")>
      <cffile file="#tempPath#\application.cfc" action="write" output="#result#">

      <!--- Replace application.cfc with binaryCacheDefinitions --->
      <cfset myFile="">
		<cffile file="#tempPath#\application.cfc" action="read" variable="myFile">
		<cfset result=Replace(#myFile#, "[[*memoryCacheDefinitionsForGPB*]]", "#binaryCacheDefinitions#", "all")>
      <cffile file="#tempPath#\application.cfc" action="write" output="#result#">
	  	
      <!--- Delete base "items" files from temp folder --->
		<cffile file="#tempPath#\api\#arguments.apiVersion#\csv\items.cfm" action="delete">
		<cffile file="#tempPath#\api\#arguments.apiVersion#\rest\items.cfm" action="delete">
		<cffile file="#tempPath#\api\#arguments.apiVersion#\soap\WSItems.cfc" action="delete">
		<cffile file="#tempPath#\api\#arguments.apiVersion#\xml\items.cfm" action="delete">
		<cffile file="#tempPath#\api\#arguments.apiVersion#\binary\items.cfm" action="delete">
		
		<cfif FileExists("#tempPath#\api\#arguments.apiVersion#\kml\items.cfm")>
		   <cffile file="#tempPath#\api\#arguments.apiVersion#\kml\items.cfm" action="delete">
		</cfif>

		<cfif FileExists("#tempPath#\api\#arguments.apiVersion#\GeoJSON\items.cfm")>
		   <cffile file="#tempPath#\api\#arguments.apiVersion#\GeoJSON\items.cfm" action="delete">
		</cfif>


      <!--- Copy LIBS and JAVALOADER --->
		<cfdirectory action="create" directory="#tempPath#\javaloader">			
	 	<cfinvoke method="copyFolder" returnvariable="result" sourceFolder="#sourcePath#\lib" destinationFolder="#tempPath#\lib">
		<cfif #arguments.createAndroidClient# EQ "true">
		   <cfinvoke method="copyFolder" returnvariable="result" sourceFolder="#sourcePath#\lib_Android" destinationFolder="#tempPath#\clients\android\libs">
		</cfif>
		<cfzip action="unzip" destination="#tempPath#\javaloader" 
		file="#sourcePath#\JL\javaloader.zip"
		overwrite="true" />
	   	   
	   <!--- Copy generated Jars to lib folder --->
	   <cftry>
	      <cffile action="copy" destination="#tempPath#\lib\#apiName#_GoogleProtocolBuffers.jar" source="#tempPath#\..\#apiName#_GoogleProtocolBuffers.jar">
	   <cfcatch>
	   </cfcatch>
	   </cftry>
	   	   
      <!--- Delete Android Client base files if user said not to create APP --->
      <cfif #arguments.createAndroidClient# NEQ "true">
	  	   <cfdirectory action="delete" directory="#tempPath#\clients" recurse="true">
		   <cfdirectory action="delete" directory="#tempPath#\lib_Android" recurse="true">
	  	</cfif>

      <!--- Delete Java Source directory needed to build Jars --->
  	   <cfdirectory action="delete" directory="#tempPath#\proto\sources" recurse="true">

		   <!--- Delete zip file if it exists --->
		   <cfif FileExists("#destinationPath#\#apiName#.zip")>
		      <cffile action="delete" file="#destinationPath#\#apiName#.zip">
		   </cfif>
		
			<!--- Delete JavaLoader temp folder --->
			<cfdirectory action="delete" directory="#tempPath#\JL" recurse="true">

         <!--- Delete temp jar and txt files --->
		   <cftry>
   		   <cffile action="delete" file="#tempPath#\..\#apiName#_GoogleProtocolBuffers.jar"> 
		   <cfcatch>
		   </cfcatch>
		   </cftry>
		   
		   <cftry>
     		   <cffile action="delete" file="#tempPath#\..\filenames.txt">
		   <cfcatch>
		   </cfcatch>
		   </cftry>

						
			<!--- Zip temp folder and copy zip file to output folder (api) --->
			<cfzip action="zip"
			source="#tempPath#\.."
			file="#destinationPath#\#apiName#.zip"
			overwrite="true"
			/>

         <!--- Delete temp folder --->
			<cfdirectory action="delete" directory="#tempPath#" recurse="true">

			<cfset result="true">
     	  
	  <cfreturn result>
   </cffunction>

   <cffunction name="copyFolder"
               access="remote"
			      returntype="string" output="no" hint="Copies recursively directories and its contents.">

      <cfargument name="sourceFolder" type="string" required="true">
      <cfargument name="destinationFolder" type="string" required="true">
        
      <cfset var result="false">

 	   <cfdirectory action="list" directory="#arguments.sourceFolder#" name="fileList">

		<cfoutput query="fileList">
        <cfif Type EQ "Dir">
		     <cfif #findNoCase("svn", name)# EQ 0>
			     <cfdirectory action="create" directory="#destinationFolder#\#name#">
			     <cfinvoke method="copyFolder" returnvariable="response" sourceFolder="#arguments.sourceFolder#\#name#" destinationFolder="#arguments.destinationFolder#\#name#">
	           <cfif #response# EQ "true">
	              <cfset result="true">
				  </cfif>
			  </cfif>
		  <cfelseif Type EQ "File">
		  	  <cfif #findNoCase("svn", name)# EQ 0>
		        <cffile action="copy" source="#arguments.sourceFolder#\#name#" destination="#arguments.destinationFolder#\#name#">
				</cfif>
           <cfset result="true">
		  </cfif>
      </cfoutput>    
      
      <cfreturn result>
   </cffunction>  
   
   <cffunction name="getNewToken"
			      returntype="string"
			      access="remote"
               output="false"> 
			   	   
      <cfreturn #createUUID()#>
  
   </cffunction>     

   <cffunction name="getDataSources"
			      returntype="Any"
			      access="remote"
               output="false"> 
			 
      <cfset objDS = createobject("java","coldfusion.server.ServiceFactory").getDatasourceService().getDatasources() />			 
			   	   
      <cfreturn #objDS#>
  
   </cffunction>     
                     
   <cffunction name="makeEntryPoint"
	          returntype="string"
				 access="remote"
				 output="false">

      <cfargument name="format" type="string" required="true">
      <cfargument name="name" type="string" required="true">
      <cfargument name="version" type="string" required="true">
      <cfargument name="views" type="string" required="true">
				 	
		<cfset var result="">
		
		<cfset NL = CreateObject("java", "java.lang.System").getProperty("line.separator")>
		
		<cfoutput> 
      <cfsavecontent variable="result"><cfloop index = "ListElement" list = "#views#" delimiters = ",">http://localhost/#name#/api/#version#/#format#/<cfif #format# EQ 'soap'>WS#listElement#.cfc?wsdl<cfelse>#listElement#.cfm</cfif><cfif not #listLast(views)# EQ #listElement#><br></cfif></cfloop></cfsavecontent></cfoutput> 	
      
      <cfreturn result>
					
   </cffunction>
            
<cffunction name="getCSVFields" output="false" access="remote" returntype="string">

   <!--- Input parameters --->
	<cfargument name="filePath" type="string" required="true">
	
	<!--- Variable definitions --->
	<cfset var fields="">
	<cfset var crlf = chr(13) & chr (10)>
	
	<!--- Open CSV file for reading --->
	<cffile file="#filePath#" action="read" variable="fileIn">
		
	<!--- Iterate through lines --->
	<cfloop list="#fileIn#" index="line" delimiters="#crlf#">
		
      <cfset fields = Replace(line, ";", ",", "all")>

      <cfbreak>
		</cfloop>
	
   <cfreturn fields>

</cffunction>      
      
<cffunction name="deAccent" access="remote" returntype="string"> 

	<cfargument name="str" type="string" required="true">
	
	<cfset var result="">
	
    <cfscript>
		 Normalizer = createObject("java","java.text.Normalizer");
	    NormalizerForm = createObject("java","java.text.Normalizer$Form");
	    normalizedString = Normalizer.normalize(str, createObject("java","java.text.Normalizer$Form").NFD);
	    pattern = createObject("java","java.util.regex.Pattern").compile("\p{InCombiningDiacriticalMarks}+");
	    	    
	    result = pattern.matcher(normalizedString).replaceAll("");
	    
    </cfscript>

    <cfreturn #lcase(result)#>

</cffunction>

<cffunction name="removeUnderscore" access="remote" returntype="string">

	<cfargument name="str" type="string" required="true">
	
	<cfset var result="">
	<cfset result = replaceNoCase(#arguments.str#, "_", "", "all")>
	
   <cfreturn #result#>

</cffunction>

      
</cfcomponent>