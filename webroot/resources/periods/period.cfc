<cfcomponent extends="taffy.core.resource" taffy:uri="/periods/{periodID}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="periods" datasource="startfly">
		SELECT 
		periods.*
		FROM periods 
		WHERE periods.status = 1 
		AND periods.ID = '#arguments.periodID#' 
		ORDER BY periods.sortOrder
		</cfquery>


		<cfset data = structNew() />

		<cfif periods.recordCount gt 0>
			
			<cfset result['data']['periodID'] = periods.ID />
			<cfset result['data']['name'] = periods.name />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


	<cffunction name="patch" access="public" output="false">
		<cfargument name="periodID" type="string" required="true" />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery datasource="startfly">
		UPDATE periods SET 
		name = '#arguments.name#',
		status = #arguments.status#
		WHERE ID = '#arguments.periodID#' 
		</cfquery>

		<cfset result['arguments'] = arguments />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>

	<cffunction name="delete" access="public" output="false">
		<cfargument name="periodID" type="string" required="true" />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE periods 
		SET deleted = 1 
		WHERE ID = '#arguments.periodID#'
		</cfquery>

		<cfset result['data']['periodID'] = arguments.periodID />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
