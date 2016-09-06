<cfcomponent output="no" displayname="environment">
<cfprocessingdirective pageencoding = "UTF-8" />

	<cffunction name="createTables" access="remote" hint="Creates needed tables on database" returntype="boolean">
		
		<cfset var result = false>
		
		<cftry>
			<cfquery datasource="[[*apiName*]]Dynamic">
				CREATE TABLE review
				(
					item_id                  INTEGER,
				   item_type                VARCHAR(100) NOT NULL,
				   item_description         VARCHAR(200) NOT NULL,
				   subItem_id               VARCHAR(100),
				   subItem_descrpition      VARCHAR(200),
				   user_id                  VARCHAR(100) NOT NULL,
				   rate                     INTEGER NOT NULL,
					comment                  VARCHAR(255)
				)
			</cfquery>	
		
		   <cfset result = true>
		      
		<cfcatch type="any">
		</cfcatch>
		</cftry>
		
		<cfreturn result>
		
	</cffunction>
	
</cfcomponent>
