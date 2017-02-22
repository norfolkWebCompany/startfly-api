<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/qualifications/update" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="qualification" type="struct" required="true" />


			<cfset objTools = createObject('component','/resources/private/tools') />

			<cfset sTime = getTickCount() />

			<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset result['data'] = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />


			<cfquery name="q" datasource="startfly">
			UPDATE partnerQualifications SET 
			grade = '#arguments.qualification.grade#',
			description = '#arguments.qualification.description#'
			WHERE sID = '#arguments.qualification.ID#' 
			AND partnerID = #internalPartnerID#
			</cfquery>


			<cfset objTools.runtime('post', '/partner/{partnerID}/qualifications/update', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
