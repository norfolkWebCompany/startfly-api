<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/images/{imageID}" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="imageID" type="string" required="true" />
		<cfargument name="shown" type="numeric" required="true" />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE partnerImages SET 
		shown = #arguments.shown# 
		WHERE ID = '#arguments.imageID#' 
		AND partnerID = '#arguments.partnerID#'
		</cfquery>
		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
