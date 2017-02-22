<cfcomponent extends="taffy.core.resource" taffy:uri="/periods" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="periods" datasource="startfly">
		SELECT 
		periods.*
		FROM periods 
		WHERE periods.status = 1 
		ORDER BY periods.sortOrder
		</cfquery>



		<cfif periods.recordCount gt 0>
			
			<cfloop query="periods">
				<cfset result['data'][periods.currentRow]['ID'] = periods.ID />
				<cfset result['data'][periods.currentRow]['name'] = periods.name />
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
		INSERT INTO periods (
		ID,
		name,
		created
		) VALUES (
		#ID#,
		'#arguments.name#',
		NOW()
		)
		</cfquery>

		<cfset result['data']['ID'] = ID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
