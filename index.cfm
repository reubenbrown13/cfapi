<cfset #application.version# = "1.1.2">
<cfajaxproxy cfc="cfapi.cfc.generator" jsclassname="generator"> 
<html>
	<head>
		<title><cfoutput>#application.title#</cfoutput></title>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
			
		<style>
			.entryPointText
			{
				background-color:#bbddFF;
				border:none;width:500px;
				height:auto;
				word-wrap:break-word;
				font-family:courier;
				font-size:small;
			}
			
			input
			{
				padding:5px;
			}
			
			.titleRow
			{
				background-color:white;
				border:1px solid grey;
				font-family:courier;
				font-size:small;
				font-weight:bold;
				color:black;
				margin:-10px;
				width:100%;
				height:20px;
			}
			
			body
			{
				background:black;
				color:white;
			}
			
			td
			{
				color:black;
			}
			
			.container
			{
				position:absolute;
				left:50%;
				margin-left:-675px;
				width:1500px;	
				padding-top:20px;			
				padding-bottom:20px;
			}
			
			*
			{
            .border-radius(0) !important;
         }

         #field
			{
				margin-bottom:20px;
         }
			
		</style>	
				
		<script language="JavaScript">
            function getUUID()
				{ 
               var g = new generator();
               var token = '';
					
					token = g.getNewToken();

               return token;
            }

            function getEntryPoint(format, apiName, apiVersion, pluralViewName)
				{ 
               var g = new generator();
               var entryPoint = '';
					
					entryPoint = g.makeEntryPoint(format, apiName, apiVersion, pluralViewName)

               return entryPoint;
            }

				
				function verifyFields()
				{
					if (document.getElementById('idApiName').value == '')
					{
						alert('The API Name is mandatory');
						return false;
					}
					
					if (document.getElementById('idApiVersion').value == '')
					{
						alert('The API Version must be informed');
						return false;
					}
					
					if (document.getElementById('idDataSourceName').value == '')
					{
						alert('A datasource must be informed');
						return false;
					}
					
					if (document.getElementById('idViewName').value == '')
					{
						alert('View name is mandatory');
						return false;
					}
					
					if (document.getElementById('idPluralViewName').value == '')
					{
						alert('Plural View Name must be informed');
						return false;
					}
					
					if (document.getElementById('idSearchFilter').value == '') 
					{
						alert('Search Filter field is mandatory');
						return false;
					}
					
					
					if (document.getElementById('idSearchFilterType').value == '') 
					{
						alert('Search Filter Type is mandatory');
						return false;
					}
					
					if (document.getElementById('idSearchFilterSize').value == '') 
					{
						alert('Search Filter Size is mandatory');
						return false;
					}
					
					if (document.getElementById('idDaysInCache').value == '') 
					{
						alert('Days in Cache must be set');
						return false;
					}
					
					if (document.getElementById('idHoursInCache').value == '') 
					{
						alert('Hours in Cache must be set');
						return false;
					}
					
					if (document.getElementById('idMinutesInCache').value == '') 
					{
						alert('Minutes in Cache must be set');
						return false;
					}
					
					if (document.getElementById('idSecondsInCache').value == '') 
					{
						alert('Seconds in Cache must be set');
						return false;
					}
					
					if (document.getElementById('idToken').value == '') 
					{
						alert('An access token must be specified');
						return false;
					}
					
					if (verifyDoubleOccur())
					{
			   	   document.form.submit();
			      }
					
			   }
 					
				function fillEntryPoints()
				{
					var format='';					
					var name='';
					var version='';
					var plural='';
					
					format='rest';
					name=document.getElementById('idApiName').value;
					version=document.getElementById('idApiVersion').value;
					plural=document.getElementById('idPluralViewName').value;
					document.getElementById('idEpRest').innerHTML=getEntryPoint(format, name, version, plural);

					format='csv';
					document.getElementById('idEpCsv').innerHTML=getEntryPoint(format, name, version, plural);

					format='soap';
					document.getElementById('idEpSoap').innerHTML=getEntryPoint(format, name, version, plural);

					format='xml';
					document.getElementById('idEpXML').innerHTML=getEntryPoint(format, name, version, plural);

				}
								
				
					// Create dynamically CSV file html form fields.
					$(document).ready(function(){
					    var next = 1;
					    $(".add-more").click(function(e){
					        e.preventDefault();
					        var addto = "#field" + next;
					        var addRemove = "#field" + (next);
					        next = next + 1;
					        var newIn = '<input autocomplete="off" class="input form-control" id="field' + next + '" name="field' + next + '" type="file" accept=".csv">';
					        var newInput = $(newIn);
					        var removeBtn = '<button id="remove' + (next - 1) + '" class="btn btn-danger remove-me" >-</button></div><div id="field">';
					        var removeButton = $(removeBtn);
					        $(addto).after(newInput);
					        $(addRemove).after(removeButton);
					        $("#field" + next).attr('data-source',$(addto).attr('data-source'));
					        $("#count").val(next);  
					        
					            $('.remove-me').click(function(e){
					                e.preventDefault();
					                var fieldNum = this.id.charAt(this.id.length-1);
					                var fieldID = "#field" + fieldNum;
					                $(this).remove();
					                $(fieldID).remove();
					            });
					    });
					});				
				
				   function verifyDoubleOccur()
					{
						var pluralViewNames = $("#idPluralViewName").val().split(",");
						var fetch="";
						var notFound=true;
						
						$(".input").each(function() {
                      fetch=$(this).val();
							 fetch=fetch.substr(0, fetch.length-4); 
							 
							 for(i=0;i<pluralViewNames.length;i++)
							 {
							    if (pluralViewNames[i] == fetch)
								 {
								 	alert('Datasets with same name defined in different sources, which is not allowed! (' + fetch + ')');
									notFound=false;
								 }	
							 } 
							 
                  });
						 
						if (notFound == true)
						{
							return true;
						}
						else
						{
							return false;
						} 
						 
					}
				
		</script>
	</head>
	
	<body style="overflow-x:hidden;" onLoad="fillEntryPoints();document.getElementById('idCSVFileList').innerHTML = '';">
		<div class="container">
		<cfoutput>
		<h1>#application.name# (#application.version#)</h1>
		<h5>#listGetAt(application.title, 2, "-")#</h5>
		<cfform name="form" action="createApi.cfm" method="post" enctype="multipart/form-data">
			    <span style="text-align:left;font-size:14px;font-family:Verdana, Arial, Helvetica, sans-serif;">
				  Please specify details for a new API to be created:</span>
		        <br>   
			    <table bgcolor="##bbddFF" cellpadding="10" cellspacing="0" style="border:1px solid grey;" width="90%">
             <tr class="titleRow">
				    <td width="100%" colspan="5">API identification</td>
             </tr>
				 <tr valign="top">
				    <td>
						API Name<br>
						<cfinput type="text" name="apiName" id="idApiName" value="bookclub" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
			       </td>
					 <td>
						API Access token &nbsp;&nbsp;<span style="color:red;cursor:pointer;" onclick="document.getElementById('idToken').value=getUUID();">(click to change)</span><br>
						<cfinput type="text" id="idToken" name="accessToken" value="#createUuid()#" style="width:288px;" onFocus="fillEntryPoints();"><br><br>
					 </td>
				 </tr>
				 </table>
				 
				 <table bgcolor="##bbddFF" cellpadding="10" cellspacing="0" style="border:1px solid grey;" width="90%">
             <tr class="titleRow">
				    <td width="100%" colspan="5">Database sourced datasets</td>
             </tr>
	          <tr>
	             <td align="left">
	             	 <cfinput type="checkbox" name="createDatabaseSourced" value="true" style="width:auto;" checked>&nbsp;Generate database sourced datasets<br><br> 
		       	 </td>
	          </tr>

				 <tr valign="top">	 
					 <td width="10%">
						<cfinput type="hidden" name="apiVersion" id="idApiVersion" value="v1" style="width:200px;" onFocus="fillEntryPoints();">
								
						Datasource Name<br>

                  <cfinput type="text" name="dataSourceName" id="idDataSourceName" value="cfbookclub" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
		
						Database View(s) Name(s)<br>
						<cfinput type="text" name="viewName" id="idViewName" value="authors,books" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
				
						View Name(s) in plural<br>
						<cfinput type="text" name="pluralViewName" id="idPluralViewName" value="authors,books" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
				
		            </td>
		            <td width="10%">							
				
						Search filter fields (one per view)<br>
						<cfinput type="text" name="searchFilter" id="idSearchFilter" value="lastname,title" style="width:200px;" onFocus="fillEntryPoints();"><br><br>

					   Search filter types<br>
					   <cfinput type="text" name="searchFilterType" id="idSearchFilterType" value="string,string" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
			
						Search filter field sizes<br>
						<cfinput type="text" name="searchFilterSize" id="idSearchFilterSize" value="50,255" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
										
						Days in cache<br>
						<cfinput type="text" name="daysInCache" id="idDaysInCache" value="0" style="width:200px;" onFocus="fillEntryPoints();"><br><br>

		            </td>
		            <td width="10%">			
			
						Hours in cache<br>
						<cfinput type="text" name="hoursInCache" id="idHoursInCache" value="0" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
				
						Minutes in cache<br>
						<cfinput type="text" name="minutesInCache" id="idMinutesInCache" value="0" style="width:288px;" onFocus="fillEntryPoints();"><br><br>
					            	
					   Seconds in cache<br>
					   <cfinput type="text" name="secondsInCache" id="idSecondsInCache" value="30" style="width:288px;" onFocus="fillEntryPoints();"><br><br>
					            		            
  		            </td>
					</tr>
					</table>

				 <table bgcolor="##bbddFF" cellpadding="10" cellspacing="0" style="border:1px solid grey;" width="90%">
             <tr class="titleRow">
				    <td width="100%" colspan="5">CSV file sourced datasets</td>
             </tr>
	          <tr>
	             <td align="left">
	             	 <cfinput type="checkbox" name="createCsvSourced" value="true" style="width:auto;">&nbsp;Generate CSV sourced datasets<br><br> 
		       	 </td>
	          </tr>				 
				 <tr valign="top" style="vertical-align:top;">	 
					 <td width="8%" valign="top" style="vertical-align:top;">
							<div class="row">
								<input type="hidden" name="count" value="1" />
						        <div class="control-group" id="fields">
						            <label class="control-label" for="field1">File Name(s)</label>
						            <div class="controls" id="profs"> 
						                <form class="input-append">
						                    <div id="field"><input autocomplete="off" class="input" id="field1" name="field1" type="file" accept=".csv" data-items="8"/><button id="b1" class="btn add-more" type="button">+</button></div>
						                </form>
						            <br>
						            <small>Press + to add another file</small>
						            </div>
						        </div>
							</div>
                  
						
				      
				      <br><br>
										
		            </td>
		            <td width="10%">							
				
						Search filter fields (one per file)<br>
						<cfinput type="text" name="CSVSearchFilter" id="idCSVSearchFilter" value="" style="width:200px;" onFocus="fillEntryPoints();"><br><br>

					   Search filter types<br>
					   <cfinput type="text" name="CSVSearchFilterType" id="idCSVSearchFilterType" value="" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
			
						Search filter field sizes<br>
						<cfinput type="text" name="CSVSearchFilterSize" id="idCSVSearchFilterSize" value="" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
										
						Days in cache<br>
						<cfinput type="text" name="CSVDaysInCache" id="idCSVDaysInCache" value="0" style="width:200px;" onFocus="fillEntryPoints();"><br><br>

		            </td>
		            <td width="10%">			
			
						Hours in cache<br>
						<cfinput type="text" name="CSVHoursInCache" id="idCSVHoursInCache" value="0" style="width:200px;" onFocus="fillEntryPoints();"><br><br>
				
						Minutes in cache<br>
						<cfinput type="text" name="CSVMinutesInCache" id="idCSVMinutesInCache" value="0" style="width:288px;" onFocus="fillEntryPoints();"><br><br>
					            	
					   Seconds in cache<br>
					   <cfinput type="text" name="CSVSecondsInCache" id="idCSVSecondsInCache" value="30" style="width:288px;" onFocus="fillEntryPoints();"><br><br>
					            		            
  		            </td>

  	             </td>
			 	 </tr>
				 </table>

						
					<table bgcolor="##bbddFF" cellpadding="10" cellspacing="0" style="border:1px solid grey;" width="90%" height="75%">
		             <tr class="titleRow">
						    <td width="100%" colspan="5">Predicted entry-points</td>
		             </tr>
	    				<tr valign="top">
	    					<td>
							<table>
							   <tr>
							      <td>Rest/JSON<br><br>
									<div id="idEpRest" name="epRest" class="entryPointText"></div>
									<br>
									</td>
							   </tr>
							   <tr>
							      <td>CSV<br><br>
									<div id="idEpCsv" name="epCsv" class="entryPointText"></div>
									<br>
									</td>
							   </tr>
							   <tr>
							      <td>SOAP<br><br>
									<div id="idEpSoap" name="epSoap" class="entryPointText"></div>								
									<br>
									</td>
							   </tr>
							   <tr>
							      <td>XML<br><br>
									<div id="idEpXML" name="epXML" class="entryPointText"></div>
									</td>
							   </tr>
							</table>
							</td>
						</tr>					
            </table>		            
				
				<table bgcolor="##bbddFF" cellpadding="10" cellspacing="0" style="border:1px solid grey;" width="90%" height="75%">
               <tr class="titleRow">
				      <td width="100%" colspan="5">Android APP Settings</td>
               </tr>

				   <tr valign="top">
	               <td width="60%">			
					      <table>
					         <tr>
					            <td align="left">
					            	<cfinput type="checkbox" name="createAndroidClient" value="true" style="width:auto;">&nbsp;Generate native Android APP<br><br> 
						      	</td>
					         </tr>
					   
						      <tr>
					            <td>
					      	      Database view name to feed APP (must have latitude and longitude fields)<br>
								      <cfinput type="text" name="viewForAndroid" value="" style="width:400px;" placeholder="myView"><br><br> 
							      </td>
						      </tr>				   	
	
								<tr>
							      <td>
							      	Endpoint domain the APP will consume<br>
										<cfinput type="text" name="endPointDomain" value="" style="width:400px;" placeholder="www.myServer.com"><br><br> 
									</td>
								</tr>				   	
			
								<tr>
							      <td>
							      	Initial Map Latitude<br>
										<cfinput type="text" name="initialMapLatitude" value="" style="width:400px;" placeholder="-99.999999"><br><br> 
									</td>
								</tr>				   	
	
								<tr>
							      <td>
							      	Initial Map Longitude<br>
										<cfinput type="text" name="initialMapLongitude" value="" style="width:400px;" placeholder="-99.999999"><br><br>
									</td>
								</tr>				   	
																		
							</td>
					   </tr>
					</table>
			</table>

			<table bgcolor="##bbddFF" cellpadding="15" cellspacing="0" style="border:1px solid grey;" width="90%">
				<tr style="border:1px solid grey;height:90px;" align="center">
			      <td>
					   <cfinput type="button" name="btnGenerate" value="Generate" onclick="document.form.confirma.value=2;verifyFields();" style="font-size:18px;padding:5px;margin:5px;">
			      </td>
			   </tr>
			   <cfinput type="hidden" value="0" name="confirma">
			</table>
		      
	</cfform>
	</div>
	</cfoutput>
		
		
	</body>
</html>