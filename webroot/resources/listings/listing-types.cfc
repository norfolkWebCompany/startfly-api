<cfcomponent extends="taffy.core.resource" taffy:uri="/listings/types" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="q" datasource="startfly">
		SELECT 
		listingType. *
		FROM listingType 
		ORDER BY listingType.sortOrder
		</cfquery>


		<cfset data = arrayNew(1) />

		<cfif q.recordCount gt 0>
			

			<cfloop query="q">
				
				<cfset data[q.currentRow]['ID'] = q.ID />
				<cfset data[q.currentRow]['name'] = q.name />
				<cfset data[q.currentRow]['info'] = q.info />

			</cfloop>


			<cfset result['data'] = data />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
