<cfcomponent extends="taffy.core.resource" taffy:uri="/foodAllergies" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="foodAllergies" datasource="startfly">
		SELECT 
		foodAllergies.*
		FROM foodAllergies 
		WHERE foodAllergies.status = 1 
		ORDER BY foodAllergies.name
		</cfquery>



		<cfif foodAllergies.recordCount gt 0>
			
			<cfloop query="foodAllergies">
				<cfset result['data'][foodAllergies.currentRow]['ID'] = foodAllergies.sID />
				<cfset result['data'][foodAllergies.currentRow]['name'] = foodAllergies.name />
				<cfset result['data'][foodAllergies.currentRow]['status'] = foodAllergies.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/foodAllergies', (getTickCount() - sTime) ) />

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
		INSERT INTO foodAllergies (
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


		<cfset objTools.runtime('post', '/foodAllergies', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
