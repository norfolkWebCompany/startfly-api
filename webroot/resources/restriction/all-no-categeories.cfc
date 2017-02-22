<cfcomponent extends="taffy.core.resource" taffy:uri="/restrictionOptions/nocat" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="options" datasource="startfly">
		SELECT 
		restrictionOption.*
		FROM restrictionOption 
		WHERE restrictionOption.status = 1 
		AND restrictionOption.deleted = 0
		</cfquery>

		<cfloop query="options">
			<cfset result['data'][options.sID]['selected'] = options.selected />
		</cfloop>


		<cfset objTools.runtime('get', '/restrictionOptions/nocat', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
