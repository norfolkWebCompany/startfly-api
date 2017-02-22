<cfcomponent extends="taffy.core.resource" taffy:uri="/skillLevels" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="skillLevels" datasource="startfly">
		SELECT 
		skillLevels.*
		FROM skillLevels 
		WHERE skillLevels.status = 1 
		ORDER BY skillLevels.sortOrder
		</cfquery>



		<cfif skillLevels.recordCount gt 0>
			
			<cfloop query="skillLevels">
				<cfset result['data'][skillLevels.currentRow]['ID'] = skillLevels.ID />
				<cfset result['data'][skillLevels.currentRow]['name'] = skillLevels.name />
				<cfset result['data'][skillLevels.currentRow]['status'] = skillLevels.status />
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
		INSERT INTO skillLevels (
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
