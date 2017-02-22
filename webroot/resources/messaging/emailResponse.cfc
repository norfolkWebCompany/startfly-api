<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/response/{responseID}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="emailResponse" datasource="startfly">
		SELECT 
		emailResponse.*
		FROM emailResponse 
		WHERE emailResponse.sID = '#arguments.responseID#' 
		AND partnerID = #internalPartnerID#
		ORDER BY emailResponse.name
		</cfquery>


		<cfset data = structNew() />

		<cfif emailResponse.recordCount gt 0>
			

			<cfset result['data']['responseID'] = emailResponse.sID />
			<cfset result['data']['name'] = emailResponse.name />
			<cfset result['data']['content'] = emailResponse.content />


		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/partner/{partnerID}/response/{responseID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

	<cffunction name="patch" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE emailResponse SET 
		name = '#arguments.name#',
		content = '#arguments.content#' 
		WHERE sID = '#responseID#' 
		AND partnerID = #internalPartnerID#
		</cfquery>

		<cfset objTools.runtime('patch', '/partner/{partnerID}/response/{responseID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

	<cffunction name="delete" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="responseID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE emailResponse 
		SET deleted = 1 
		WHERE sID = '#arguments.responseID#'
		</cfquery>

		<cfset result['data']['responseID'] = arguments.responseID />

		<cfset objTools.runtime('delete', '/partner/{partnerID}/response/{responseID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
