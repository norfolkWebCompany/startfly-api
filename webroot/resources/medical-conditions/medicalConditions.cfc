<cfcomponent extends="taffy.core.resource" taffy:uri="/medicalConditions" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="medicalConditions" datasource="startfly">
		SELECT 
		medicalConditions.*
		FROM medicalConditions 
		WHERE medicalConditions.status = 1 
		ORDER BY medicalConditions.name
		</cfquery>



		<cfif medicalConditions.recordCount gt 0>
			
			<cfloop query="medicalConditions">
				<cfset result['data'][medicalConditions.currentRow]['ID'] = medicalConditions.sID />
				<cfset result['data'][medicalConditions.currentRow]['name'] = medicalConditions.name />
				<cfset result['data'][medicalConditions.currentRow]['status'] = medicalConditions.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/medicalConditions', (getTickCount() - sTime) ) />

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
		INSERT INTO medicalConditions (
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

		<cfset objTools.runtime('post', '/medicalConditions', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
