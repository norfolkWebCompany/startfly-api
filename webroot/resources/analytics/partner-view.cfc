<cfcomponent extends="taffy.core.resource" taffy:uri="/analytics/partner/{partnerID}/view" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="customerID" type="string" required="true" />


		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset dim = objDates.setDim({date = now()}) />


		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfquery name="doCheck" datasource="startfly">
		SELECT ID 
		FROM partnerViews 
		WHERE partnerID = #internalPartnerID# 
		AND customerID = #internalCustomerID#
		AND dateID = #dim.dateID# 
		LIMIT 1
		</cfquery>

		<cfif doCheck.recordCount is 1>
			<cfquery datasource="startfly">
			UPDATE partnerViews SET 
			views = views + 1
			WHERE ID = #doCheck.ID# 
			</cfquery>
		<cfelse>
			<cfquery datasource="startfly">
			INSERT INTO partnerViews (
			partnerID,
			customerID,
			views,
			dateID
			) VALUES (
			#internalPartnerID#,
			#internalCustomerID#,
			1,
			#dim.dateID#
			) 
			</cfquery>
		</cfif>

			<cfset objTools.runtime('post', '/analytics/partner/{partnerID}/view', (getTickCount() - sTime) ) />


		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
