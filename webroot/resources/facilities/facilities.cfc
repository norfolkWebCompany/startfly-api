<cfcomponent extends="taffy.core.resource" taffy:uri="/facilities" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="facilities" datasource="startfly">
		SELECT 
		facilities.*
		FROM facilities 
		WHERE facilities.status = 1 
		ORDER BY facilities.sortOrder
		</cfquery>

		<cfif facilities.recordCount gt 0>
			
			<cfloop query="facilities">
				<cfset result['data'][facilities.currentRow]['ID'] = facilities.sID />
				<cfset result['data'][facilities.currentRow]['name'] = facilities.name />
				<cfset result['data'][facilities.currentRow]['status'] = facilities.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/facilities', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />

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
		INSERT INTO facilities (
		ID,
		sID,
		name,
		status,
		created
		) VALUES (
		#ID#,
		'#sID#',
		'#arguments.name#',
		1,
		NOW()
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />

		<cfset objTools.runtime('post', '/facilities', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
