<cfcomponent extends="taffy.core.resource" taffy:uri="/location/types" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="locationTypes" datasource="startfly">
		SELECT 
		locationTypes.*
		FROM locationTypes 
		WHERE locationTypes.status = 1 
		ORDER BY locationTypes.sortOrder
		</cfquery>



		<cfif locationTypes.recordCount gt 0>
			
			<cfloop query="locationTypes">
				<cfset result['data'][locationTypes.currentRow]['ID'] = locationTypes.ID />
				<cfset result['data'][locationTypes.currentRow]['name'] = locationTypes.name />
				<cfset result['data'][locationTypes.currentRow]['status'] = locationTypes.status />
				<cfset result['data'][locationTypes.currentRow]['type'] = locationTypes.type />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/location/types', (getTickCount() - sTime) ) />

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

		<cfset ID = objAccum.newID('locationType') />

		<cfquery datasource="startfly">
		INSERT INTO locationTypes (
		ID,
		name,
		status,
		created
		) VALUES (
		#ID#,
		'#arguments.name#',
		1,
		NOW()
		)
		</cfquery>

		<cfset result['data']['ID'] = ID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />


		<cfset objTools.runtime('get', '/location/types', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
