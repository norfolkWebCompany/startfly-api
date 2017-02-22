<cfcomponent extends="taffy.core.resource" taffy:uri="/phobias" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="phobias" datasource="startfly">
		SELECT 
		phobias.*
		FROM phobias 
		WHERE phobias.status = 1 
		ORDER BY phobias.name
		</cfquery>



		<cfif phobias.recordCount gt 0>
			
			<cfloop query="phobias">
				<cfset result['data'][phobias.currentRow]['ID'] = phobias.sID />
				<cfset result['data'][phobias.currentRow]['name'] = phobias.name />
				<cfset result['data'][phobias.currentRow]['status'] = phobias.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/phobias', (getTickCount() - sTime) ) />

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
		INSERT INTO phobias (
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

		<cfset objTools.runtime('post', '/phobias', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
