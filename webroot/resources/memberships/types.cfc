<cfcomponent extends="taffy.core.resource" taffy:uri="/membership/types" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="membershipTypes" datasource="startfly">
		SELECT 
		membershipTypes.*
		FROM membershipTypes 
		WHERE membershipTypes.status = 1 
		ORDER BY membershipTypes.sortOrder
		</cfquery>



		<cfif membershipTypes.recordCount gt 0>
			
			<cfloop query="membershipTypes">
				<cfset result['data'][membershipTypes.currentRow]['ID'] = membershipTypes.ID />
				<cfset result['data'][membershipTypes.currentRow]['name'] = membershipTypes.name />
				<cfset result['data'][membershipTypes.currentRow]['status'] = membershipTypes.status />
				<cfset result['data'][membershipTypes.currentRow]['type'] = membershipTypes.type />
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

		<cfset ID = objAccum.newID('membershipType') />

		<cfquery datasource="startfly">
		INSERT INTO membershipTypes (
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


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
