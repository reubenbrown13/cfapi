<!---

   Project : CFapi
   Author  : Luiz Milfont
   Date    : 29/09/2015
 
 --->


<!--- Set default charset to UTF-8 --->
<cfprocessingdirective pageencoding="UTF-8">
<cfcontent type="text/html; charset=UTF-8">
<cfset setEncoding("URL", "UTF-8")>
<cfset setEncoding("Form", "UTF-8")>

<!--- Redirect errors to custom page --->
<cferror type="exception" template="error.cfm">
<cferror type="request" template="error.cfm">

<!--- Set application configuration --->
<cfapplication name="CFapi" SESSIONMANAGEMENT="Yes"  loginStorage="session" clientmanagement="no" sessiontimeout=#CreateTimeSpan(0, 0, 20, 0)# />

<cflock scope="application" timeout="600">
	<cfif not isdefined("application.title")>
	   <cfparam name="application.title" type="string" default="CFapi - Coldfusion dynamic API generator">
	</cfif>
	<cfif not isdefined("application.name")>
	   <cfparam name="application.name" type="string" default="CFapi">
	</cfif>
	<cfif not isdefined("application.version")>
	   <cfparam name="application.version" type="string" default="">
	</cfif>
	<cfif not isdefined("application.kmlFiles")>
	   <cfparam name="application.kmlFiles" type="string" default="">
	</cfif>
	<cfif not isdefined("application.geoFiles")>
	   <cfparam name="application.geoFiles" type="string" default="">
	</cfif>
</cflock>
