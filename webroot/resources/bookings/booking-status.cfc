<cfcomponent extends="taffy.core.resource" taffy:uri="/bookingStatus" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="bookingStatus" datasource="startfly">
		SELECT 
		bookingStatus.*
		FROM bookingStatus 
		WHERE bookingStatus.status = 1 
		ORDER BY bookingStatus.sortOrder
		</cfquery>



		<cfloop query="bookingStatus">
			<cfset result['data'][bookingStatus.currentRow]['ID'] = bookingStatus.ID />
			<cfset result['data'][bookingStatus.currentRow]['name'] = bookingStatus.name />
		</cfloop>

		<cfset objTools.runtime('get', '/bookingStatus', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
