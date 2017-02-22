<cfcomponent extends="taffy.core.resource" taffy:uri="/languages" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="languages" datasource="startfly">
		SELECT 
		languages.*
		FROM languages 
		WHERE languages.status = 1 
		ORDER BY languages.name
		</cfquery>



		<cfif languages.recordCount gt 0>
			
			<cfloop query="languages">
				<cfset result['data'][languages.currentRow]['ID'] = languages.sID />
				<cfset result['data'][languages.currentRow]['name'] = languages.name />
				<cfset result['data'][languages.currentRow]['status'] = languages.status />
				<cfset result['data'][languages.currentRow]['selected'] = languages.selected />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/languages', (getTickCount() - sTime) ) />

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

		<cfset ID = objAccum.newID('secureIDPrefix') & '-' & createUUID() />
		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO languages (
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

		<cfset objTools.runtime('post', '/languages', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
