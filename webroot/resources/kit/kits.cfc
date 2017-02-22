<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/kit/{kitID}" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="kit" datasource="startfly">
		SELECT 
		kit.*,
		kitCategory.sID AS categorySID,
		kitCategory.name AS categoryName
		FROM kit 
		INNER JOIN kitCategory ON kit.category = kitCategory.ID
		WHERE kit.sID = '#arguments.kitID#' 
		AND kit.partnerID = #internalPartnerID#
		</cfquery>



		<cfif kit.recordCount gt 0>
			
			<cfset result['data']['ID'] = kit.sID />
			<cfset result['data']['name'] = kit.name />
			<cfset result['data']['category']['ID'] = kit.categorySID />
			<cfset result['data']['category']['name'] = kit.categoryName />
			<cfset result['data']['status'] = kit.status />
			<cfset result['data']['selected'] = kit.selected />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/partner/{partnerID}/kit/{kitID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE kit SET 
		name = '#arguments.name#',
		category = #arguments.category.ID#,
		status = #arguments.status#
		WHERE sID = '#arguments.kitID#' 
		AND partnerID = #internalPartnerID#
		</cfquery>

		<cfset objTools.runtime('post', '/partner/{partnerID}/kit/{kitID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

	<cffunction name="delete" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE kit SET 
		deleted = 1 
		WHERE sID = '#arguments.kitID#' 
		AND partnerID = #internalPartnerID#
		</cfquery>

		<cfset objTools.runtime('delete', '/partner/{partnerID}/kit/{kitID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
