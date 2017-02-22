<cfcomponent extends="taffy.core.resource" taffy:uri="/expenses" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="expenses" datasource="startfly">
		SELECT 
		expenses.*
		FROM expenses 
		WHERE expenses.status = 1 
		ORDER BY expenses.sortOrder
		</cfquery>

		<cfif expenses.recordCount gt 0>
			
			<cfloop query="expenses">
				<cfset result['data'][expenses.currentRow]['ID'] = expenses.sID />
				<cfset result['data'][expenses.currentRow]['name'] = expenses.name />
				<cfset result['data'][expenses.currentRow]['description'] = expenses.description />
				<cfset result['data'][expenses.currentRow]['status'] = expenses.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/expenses', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="description" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset ID = objAccum.newID('secureIDPrefix') />
		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO expenses (
		ID,
		sID,
		name,
		description,
		status
		) VALUES (
		#ID#,
		'#sID#',
		'#arguments.name#',
		'#arguments.description#',
		1
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['description'] = arguments.description />
		<cfset result['data']['status'] = 1 />

		<cfset objTools.runtime('post', '/expenses', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
