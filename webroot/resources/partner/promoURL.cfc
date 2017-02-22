<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/promoURL" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="promoURL" type="string" required="true" />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE partner SET 
		promoURL = '#arguments.promoURL#' 
		WHERE ID = '#arguments.partnerID#'
		</cfquery>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
