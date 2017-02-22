<cfcomponent extends="taffy.core.resource" taffy:uri="/membership/start" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="membershipStart" datasource="startfly">
		SELECT 
		membershipStart.*
		FROM membershipStart 
		ORDER BY membershipStart.sortOrder
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfloop query="membershipStart">
			
			<cfset dataArray[membershipStart.currentRow]['ID'] = membershipStart.ID />
			<cfset dataArray[membershipStart.currentRow]['name'] = membershipStart.name />

		</cfloop>

		<cfset result['data'] = dataArray />

		<cfset objTools.runtime('get', '/membership/start', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
