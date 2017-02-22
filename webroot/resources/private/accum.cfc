<cfcomponent>
	<cffunction name="NewId" access="public" returntype="numeric">
		<cfargument name="cId" type="string" required="yes">

			<cflock scope="application" type="exclusive" timeout="10">

				<cfquery name="c1" datasource="startfly">
				SELECT cId, cVal 
				FROM accum 
				WHERE cId = '#cId#' 
				LIMIT 1
				</cfquery>

				<cfset NewId = c1.cVal + 1>

				<cfquery datasource="startfly">
				UPDATE Accum SET
				cVal = #NewId# 
				WHERE cId = '#cId#'
				</cfquery>

			</cflock>
			  
			  <cfreturn NewId>

	</cffunction>
</cfcomponent>