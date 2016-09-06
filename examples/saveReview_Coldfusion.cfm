<!--- Coldfusion example showing how to save a review --->
<!--- Put this file in root directory of created BOOKCLUB api to show its result --->  

<!--- Instructions: 1) Instantiate a DTO.
                    2) Fill in its properties with user defined values.
                    3) Put values inside http headers remembering to serialize the DTO
                    4) Post with cfhttp.
--->


<!--- Instantiate reviewDTO object --->
<cfobject name="reviewDTO" component="bookclub.dto.reviewDTO">

<cfset reviewDTO.item_id = "1">
<cfset reviewDTO.item_type = "book">
<cfset reviewDTO.item_description = "The Road">
<cfset reviewDTO.subItem_id = "">
<cfset reviewDTO.subItem_descrpition = "">
<cfset reviewDTO.user_id = "johnSmith@hotmail.com">
<cfset reviewDTO.rate = "5">
<cfset reviewDTO.comment = "Great book">

<cfhttp url="http://localhost/bookclub/api/v1/rest/review.cfm" method="post" result="result" charset="utf-8">
  <cfhttpparam name="Accept" type="header" value="text/json" />
  <cfhttpparam name="token" type="header" value="C9B6FC47-F8C1-6802-D170C36D2D40B810" />
  <cfhttpparam name="reviewDTO" type="header" value="#serializeJson(reviewDTO)#" />
</cfhttp>


<cfoutput>
   #result.fileContent#      
</cfoutput>

