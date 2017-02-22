<cfcomponent extends="taffy.core.resource" taffy:uri="/helpgroup" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="helpgroup" datasource="startfly">
		SELECT 
		helpgroup.*
		FROM helpgroup 
		WHERE helpgroup.status = 1 
		ORDER BY helpgroup.sortOrder
		</cfquery>



		<cfif helpgroup.recordCount gt 0>
			
			<cfloop query="helpgroup">
				<cfset result['data'][helpgroup.currentRow]['ID'] = helpgroup.sID />
				<cfset result['data'][helpgroup.currentRow]['name'] = helpgroup.name />
				<cfset result['data'][helpgroup.currentRow]['status'] = helpgroup.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/helpgroup', (getTickCount() - sTime) ) />

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
		INSERT INTO helpgroup (
		sID,
		name,
		status
		) VALUES (
		'#sID#',
		'#arguments.name#',
		1
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />

		<cfset objTools.runtime('post', '/helpgroup', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
