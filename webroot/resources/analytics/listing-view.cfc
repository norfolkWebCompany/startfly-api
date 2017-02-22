<cfcomponent extends="taffy.core.resource" taffy:uri="/analytics/listings/{listingID}/view" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="listingID" type="string" required="true" />
		<cfargument name="customerID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />
		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfset dim = objDates.setDim({date = now()}) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="partner" datasource="startfly">
		SELECT 
		partnerID 
		FROM listing 
		WHERE ID = #internalListingID# 
		LIMIT 1
		</cfquery>


		<cfquery name="doCheck" datasource="startfly">
		SELECT ID 
		FROM listingViews 
		WHERE listingID = #internalListingID# 
		AND customerID = #internalCustomerID#
		AND dateID = #dim.dateID# 
		LIMIT 1
		</cfquery>

		<cfif doCheck.recordCount is 1>
			<cfquery datasource="startfly">
			UPDATE listingViews SET 
			views = views + 1
			WHERE ID = #doCheck.ID# 
			</cfquery>
		<cfelse>
			<cfquery datasource="startfly">
			INSERT INTO listingViews (
			listingID,
			partnerID,
			customerID,
			views,
			dateID
			) VALUES (
			#internalListingID#,
			#partner.partnerID#,
			#internalCustomerID#,
			1,
			#dim.dateID#
			) 
			</cfquery>
		</cfif>


		<cfset objTools.runtime('post', '/analytics/listings/{listingID}/view', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
