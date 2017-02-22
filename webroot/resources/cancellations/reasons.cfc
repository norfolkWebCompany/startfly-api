<cfcomponent extends="taffy.core.resource" taffy:uri="/cancellation/reasons" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="q" datasource="startfly">
		SELECT 
		cancellationReason.*
		FROM cancellationReason 
		ORDER BY cancellationReason.sortOrder, cancellationReason.name
		</cfquery>

		<cfloop query="q">
			<cfset result['data'][q.currentRow]['ID'] = q.ID />
			<cfset result['data'][q.currentRow]['name'] = q.name />
		</cfloop>


		<cfset objTools.runtime('get', '/cancellation/reasons', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		INSERT INTO cancellationReason (
		name
		) VALUES (
		'#arguments.name#'
		)
		</cfquery>

		<cfset result['data']['ID'] = qResult.generatedKey />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />

		<cfset objTools.runtime('post', '/cancellation/reasons', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
