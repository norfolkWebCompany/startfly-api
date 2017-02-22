<cfcomponent extends="taffy.core.resource" taffy:uri="/preferences" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="preferences" datasource="startfly">
		SELECT 
		preferences.*
		FROM preferences 
		WHERE preferences.status = 1 
		ORDER BY preferences.name
		</cfquery>



		<cfif preferences.recordCount gt 0>
			
			<cfloop query="preferences">
				<cfset result['data'][preferences.currentRow]['ID'] = preferences.sID />
				<cfset result['data'][preferences.currentRow]['name'] = preferences.name />
				<cfset result['data'][preferences.currentRow]['status'] = preferences.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/preferences', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />

		<cfset objAccum = createObject('component','/resources/private/accum') />
		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset ID = objAccum.newID('secureIDPrefix') & '-' & createUUID() />
		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO preferences (
		ID,
		sID,
		name,
		status
		) VALUES (
		#ID#,
		'#sID#',
		'#arguments.name#',
		1
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />

		<cfset objTools.runtime('post', '/preferences', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
