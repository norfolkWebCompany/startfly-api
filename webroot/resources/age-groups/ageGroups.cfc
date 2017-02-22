<cfcomponent extends="taffy.core.resource" taffy:uri="/agegroups" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="ageGroups" datasource="startfly">
		SELECT 
		ageGroups.*
		FROM ageGroups 
		WHERE ageGroups.status = 1 
		ORDER BY ageGroups.sortOrder
		</cfquery>



		<cfif ageGroups.recordCount gt 0>
			
			<cfloop query="ageGroups">
				<cfset result['data'][ageGroups.currentRow]['ID'] = ageGroups.ID />
				<cfset result['data'][ageGroups.currentRow]['name'] = ageGroups.name />
				<cfset result['data'][ageGroups.currentRow]['status'] = ageGroups.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset ID = objAccum.newID('secureIDPrefix') & '-' & createUUID() />

		<cfquery datasource="startfly">
		INSERT INTO ageGroups (
		ID,
		name,
		status,
		created
		) VALUES (
		'#ID#',
		'#arguments.name#',
		1,
		NOW()
		)
		</cfquery>

		<cfset result['data']['ID'] = ID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
