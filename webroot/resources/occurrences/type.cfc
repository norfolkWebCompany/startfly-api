<cfcomponent extends="taffy.core.resource" taffy:uri="/occurrences/types/{listingType}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="listingType" type="numeric" required="true" />
		
		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="q" datasource="startfly">
		SELECT * FROM occurrenceType 
		<!---
		WHERE listingType = #arguments.listingType# 
		AND status = 1
		--->
		WHERE status = 1
		ORDER BY sortOrder
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfloop query="q">
			<cfset dataArray[q.currentRow]['ID'] = q.ID />
			<cfset dataArray[q.currentRow]['name'] = q.name />
		</cfloop>

		<cfset result['data'] = dataArray />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
