<cfcomponent style="rpc"
			    namespace="com.[[*apiName*]]"
			    hint="SOAP WebService">
               
   <cffunction name="get_[[*pluralViewName*]]"
               returntype="[[*apiName*]].dto.[[*viewName*]][]"
               hint="[[*featureDescription*]]"
               access="remote"
			      output="false">	   
			   
     <!--- List of arguments --->
     <cfargument name="token" type="string" required="true">
     <cfargument name="filter" type="string" required="true">
					
     <!--- Variables declarations --->
     <cfset array[[*viewName*]]=ArrayNew(1)>
	  <cfset i=0>
					
  	  <!--- Arguments validation --->
  	  <cfif #len(arguments.token)# EQ 0>
	     <cfset errorMessage="The access token is mandatory">
	     <cfthrow type="custom" message="#errorMessage#;">
	  </cfif>

     <!--- Token validation --->
     <cftry>
	  	  <cfinvoke component="[[*apiName*]].data.validationGateway" method="validateToken" returnvariable="valid" token="#token#">
  	      <cfif #valid# EQ "false">
	         <cfset errorMessage="Invalid token">
	         <cfthrow type="custom" message="#errorMessage#;">
		   </cfif>		
     <cfcatch>
	     <cfset errorMessage="Invalid token">
	     <cfthrow type="custom" message="#errorMessage#;">
	  </cfcatch>
	  </cftry>  
    
     <!--- Get data for external availability as SOAP WebService --->
     <cftry>
    	  <cfinvoke component="[[*apiName*]].data.[[*viewName*]]Gateway" method="getDataFromCache[[*viewName*]][[*apiName*]]" searchValue="#filter#" returnvariable="query">

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

	  <cfcatch>
         <cfset errorMessage="Error while reading data from memory cache: " & #cfcatch.message#>
         <cfthrow type="custom" message="#errorMessage#;">
      </cfcatch>	  	  	
	  </cftry>
	        
      <!--- Return the created DTO --->
      <cfreturn array[[*viewName*]]>
   </cffunction>                   

</cfcomponent>
