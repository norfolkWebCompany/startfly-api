<cfcomponent extends="taffy.core.resource" taffy:uri="/membership/freeentry/period" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="membershipPeriod" datasource="startfly">
		SELECT 
		membershipPeriod.*
		FROM membershipPeriod 
		ORDER BY membershipPeriod.sortOrder
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfloop query="membershipPeriod">
			
			<cfset dataArray[membershipPeriod.currentRow]['ID'] = membershipPeriod.ID />
			<cfset dataArray[membershipPeriod.currentRow]['name'] = membershipPeriod.name />

		</cfloop>

		<cfset result['data'] = dataArray />

		<cfset objTools.runtime('get', '/membership/freeentry/period', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
