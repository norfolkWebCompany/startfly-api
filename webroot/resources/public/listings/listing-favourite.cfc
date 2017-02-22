<cfcomponent extends="taffy.core.resource" taffy:uri="/public/listing/favourite" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset result['data']['added'] = 0 />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />

		<cfquery name="fCheck" datasource="startfly">
		SELECT ID FROM 
		favouriteListings 
		WHERE listingID = #internalListingID# 
		AND customerID = #internalCustomerID# 
		</cfquery>

		<cfif fCheck.recordCount is 0>
			<cfquery datasource="startfly">
			INSERT INTO favouriteListings (
			customerID,
			listingID,
			created
			) VALUES (
			#internalCustomerID#,
			#internalListingID#,
			NOW()
			)
			</cfquery>

			<cfset result['data']['added'] = 1 />

		<cfelse>
			<cfquery name="fCheck" datasource="startfly">
			DELETE FROM	favouriteListings 
			WHERE listingID = #internalListingID# 
			AND customerID = #internalCustomerID# 
			</cfquery>
		</cfif>


		<cfset objTools.runtime('post', '/public/listing/favourite', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
