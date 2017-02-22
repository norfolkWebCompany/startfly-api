<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/favourites/all" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />

		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset listingArray = arrayNew(1) />
		<cfset partnerArray = arrayNew(1) />

		<cfquery name="partners" datasource="startfly">
		SELECT 
		partner.sID
		FROM favouritePartners  
		INNER JOIN partner ON favouritePartners.partnerID = partner.ID 
		WHERE favouritePartners.customerID = #internalCustomerID# 
		ORDER BY favouritePartners.created DESC
		</cfquery>

		<cfloop query="partners">
			<cfset partnerArray[partners.currentRow] = partners.sID />
		</cfloop>



		<cfquery name="listings" datasource="startfly">
		SELECT 
		listing.sID,
		listing.name
		FROM favouriteListings 
		INNER JOIN listing ON favouriteListings.listingID = listing.ID
		WHERE favouriteListings.customerID = #internalCustomerID# 
		AND listing.deleted = 0
		</cfquery>


		<cfloop query="listings">
			<cfset listingArray[listings.currentRow] = listings.sID />
		</cfloop>

		<cfset result['data']['listings'] = listingArray />
		<cfset result['data']['partners'] = partnerArray />


		<cfset objTools.runtime('post', '/customer/{customerID}/favourites', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
