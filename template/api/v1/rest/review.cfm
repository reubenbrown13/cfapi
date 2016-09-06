<!--- This endpoint is used to allow users to review/evaluate items exposed by the API --->

<cfheader name="Access-Control-Allow-Origin" value="*">
<cfset SetEncoding("URL", "UTF-8" )>

<!--- Variables definitions --->
<cfset headers = "" />
<cfset result = false />
<cfset token = "" />
<cfset reviewDTO = "">

<!--- Get the headers --->
<cfset headers=GetHttpRequestData().Headers>

<!--- List of arguments --->
<cfif isDefined("headers.token")>
   <cfset token = "#headers.token#" />
</cfif>

<cfif isDefined("headers.reviewDTO")>
   <cfset reviewDTO = "#headers.reviewDTO#" />
</cfif>


<!--- Sometimes when field is left blank, the field name is sent as its value --->						
<cfif lcase(token) EQ "token">
	<cfset token="">
</cfif>									

<!--- Arguments validation --->
<cfif #len(token)# EQ 0>
   <cfheader statuscode="500" statustext="The access token is mandatory." >
   The access token is mandatory.
   <cfabort>   
</cfif>
<cfif #len(reviewDTO)# EQ 0>
   <cfheader statuscode="500" statustext="The reviewDTO is mandatory." >
   The reviewDTO is mandatory.
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

<cfset oldLocale=setLocale("en")>	

<cftry>
	<!--- Deserialize JSON from reviewDTO --->
	<cfset reviewStruct = deserializeJson(#reviewDTO#)>
	
	<!--- Instantiate new reviewDTO object --->
	<cfobject name="newReview" component="[[*apiName*]].dto.reviewDTO">
	
	<cfset newReview.item_id = reviewStruct.item_id>
	<cfset newReview.item_type = reviewStruct.item_type>
	<cfset newReview.item_description = reviewStruct.item_description>
	<cfset newReview.subItem_id = reviewStruct.subItem_id>
	<cfset newReview.subItem_descrpition = reviewStruct.subItem_descrpition>
	<cfset newReview.user_id = reviewStruct.user_id>
	<cfset newReview.rate = reviewStruct.rate>
	<cfset newReview.comment = reviewStruct.comment>

<cfcatch>
	   <cfheader statuscode="500" statustext="Internal server error." >
	   Internal server error.
	   <cfabort>   
</cfcatch>
</cftry>  

		
<!--- Save user review --->
<cftry>
   <cfinvoke component="[[*apiName*]].data.reviewGateway" method="saveReview" returnvariable="result" review="#newReview#">
<cfcatch>
   <cfheader statuscode="500" statustext="Internal server error." >
   Internal server error.
   <cfabort>   
</cfcatch>	  	  	
</cftry>

<cfif #result# EQ true>
   <!--- If everything went fine --->
   <cfheader statuscode="201" statustext="created">
   created   
<cfelse>
   <cfheader statuscode="500" statustext="Internal server error." >
   Internal server error.
</cfif>