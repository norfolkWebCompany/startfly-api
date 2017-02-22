<cfcomponent extends="taffy.core.resource" taffy:uri="/relationships" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="relationships" datasource="startfly">
		SELECT 
		relationships.*
		FROM relationships 
		WHERE relationships.deleted = 0 
		ORDER BY relationships.sortOrder
		</cfquery>



		<cfif relationships.recordCount gt 0>
			
			<cfloop query="relationships">
				<cfset result['data'][relationships.currentRow]['ID'] = relationships.ID />
				<cfset result['data'][relationships.currentRow]['name'] = relationships.name />
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

		<cfset secureIDPrefix = objAccum.newID('secureIDPrefix') />
		<cfset ID = secureIDPrefix & RandRange(10000, 99999, "SHA1PRNG") />


		<cfquery datasource="startfly">
		INSERT INTO relationships (
		ID,
		name
		) VALUES (
		#ID#,
		'#arguments.name#'
		)
		</cfquery>

		<cfset result['data']['ID'] = ID />
		<cfset result['data']['name'] = arguments.name />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
