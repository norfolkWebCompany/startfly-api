<cfcomponent extends="taffy.core.resource" taffy:uri="/coursecategory/{id}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="id" type="string" required="true" />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="q" datasource="startfly">
			SELECT 
			courseCategory.*
			FROM courseCategory 
			WHERE secureID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" /> 
			AND status = 1 
			ORDER BY sortOrder
		</cfquery>



			<cfif q.recordCount is 1>

				<cfset result['data']['categoryID'] = q.ID />
				<cfset result['data']['parentID'] = q.parentID />
				<cfset result['data']['level'] = q.level />
				<cfset result['data']['familyID'] = q.familyID />
				<cfset result['data']['name'] = q.name />
				<cfset result['data']['sortOrder'] = q.sortOrder />
				<cfset result['data']['created'] = q.created />
	
			

			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


	<cffunction name="patch" access="public" output="false">
		<cfargument name="categoryID" type="string" required="true" />
		<cfargument name="name" type="string" required="true" />

			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />
	
			<cfquery name="q" datasource="startfly">
				UPDATE courseCategory SET 
				name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" />
				WHERE secureID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ID#" />
			</cfquery>
		
		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
