
<!---
       Create Dynamic database and datasource for user reviews/evaluation of api exposed items.
       The Server Admin password is needed to dynamically create them.
--->

<!--- Determine which CFML engine is installed and copy correct files --->
<cfset cfmlServer="#SERVER.coldfusion.productname#">

<cfif findNoCase("coldfusion", cfmlServer) GT 0>
	   <cfset cfmlServer="cf">
	<cfelseif findNoCase("railo", cfmlServer) GT 0>
   <cfset cfmlServer="railo">
<cfelseif findNoCase("lucee", cfmlServer) GT 0>     
   <cfset cfmlServer="lucee">
</cfif>

<cfif #cfmlServer# EQ "cf">
	<cfset passwd="">
	      
	<cfif isDefined("form.authorization")>
		<cfset passwd="#form.authorization#">
	</cfif>     
	   
	<cfset dsn="[[*apiName*]]Dynamic">
		
	<cfparam name="form.admin_user" default="admin">
	<cfparam name="form.admin_password" default="#passwd#">
	<cfset loginSuccessful = CreateObject("component","cfide.adminapi.administrator").login(form.admin_password, form.admin_user)>
	
	<cfif loginSuccessful>	
		<cfset datasource = CreateObject("component", "cfide.adminapi.datasource")>
		<cfset datasource.setDerbyEmbedded(
				name=dsn,
				database="#expandPath(dsn)#",
				isnewdb=true
					)>
	
	   <cfoutput>Datasource #XmlFormat(dsn)# created successfully.</cfoutput><br>
	   <cfset verify = datasource.verifyDsn(dsn, true)>
	   <cfoutput>DataSource verified: #XmlFormat(verify)#</cfoutput>
	<cfelse>
	   <p>Invalid username or password.</p>
	</cfif>

<cfelse>
	This procedure is not needed in Railo or Lucee Server CFML engines.
</cfif>
