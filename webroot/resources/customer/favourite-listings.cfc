<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/favourites/listings" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="listings" datasource="startfly">
		SELECT 
		listing.*,
		partner.firstName,
		partner.surname,
		partner.nickname,
		partner.company,
		partner.useBusinessName,
		locations.name AS locationName,
		locations.longitude,
		locations.latitude,
		locations.town,
		locations.hideAddress,
		listingType.name as typeName,
		(
			SELECT 
			IFNULL( ( SUM(reviews.rating) / COUNT(*) ),0) 
			FROM reviews 
			WHERE type = 'listing' 
			AND listingID = listing.ID 
		) AS ratingAvg
		FROM favouriteListings 
		INNER JOIN listing ON favouriteListings.listingID = listing.ID
		INNER JOIN partner ON listing.partnerID = partner.ID 
		INNER JOIN listingType ON listing.type = listingType.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		WHERE favouriteListings.customerID = #internalCustomerID# 
		AND listing.deleted = 0
		</cfquery>

		<cfset dataArray = arrayNew(1) />

			<cfloop query="listings">

				<cfquery name="categories" datasource="startfly">
				SELECT 
				courseCategory.name,
				courseCategory.URL,
				courseCategory.secureID 
				FROM listingCategory 
				INNER JOIN courseCategory ON listingCategory.categoryID = courseCategory.ID 
				WHERE listingCategory.listingID = #internalCustomerID# 
				</cfquery>
				
				<cfset dataArray[listings.currentRow]['isFavourite'] = 1 />
				<cfset dataArray[listings.currentRow]['listingID'] = listings.sID />
				<cfset dataArray[listings.currentRow]['name'] = listings.name />
				<cfset dataArray[listings.currentRow]['url'] = listings.url />
				<cfset dataArray[listings.currentRow]['listingType'] = listings.type />
				<cfset dataArray[listings.currentRow]['locationType'] = listings.locationType />
				<cfset dataArray[listings.currentRow]['typeName'] = listings.typeName />
				<cfset dataArray[listings.currentRow]['location']['name'] = listings.locationName />
				<cfset dataArray[listings.currentRow]['location']['town'] = listings.town />
				<cfset dataArray[listings.currentRow]['location']['hideAddress'] = listings.hideAddress />

				<cfset dataArray[listings.currentRow]['rating']['average'] = ceiling(listings.ratingAvg) />
				<cfset dataArray[listings.currentRow]['cost'] = listings.cost />
				<cfset dataArray[listings.currentRow]['rating'] = listings.rating />
				<cfset dataArray[listings.currentRow]['capacity'] = listings.capacity />
				<cfset dataArray[listings.currentRow]['featured'] = listings.featured />
				<cfset dataArray[listings.currentRow]['imageURL'] = listings.imageURL />
				<cfset dataArray[listings.currentRow]['previewText'] = listings.previewText />
				<cfset dataArray[listings.currentRow]['created'] = dateFormat(listings.created, "yyyy-mm-dd") & 'T' & timeFormat(listings.created,"HH:mm:ss") & 'Z' />

				<cfif listings.useBusinessName is 0>
					<cfset dataArray[listings.currentRow]['partner']['name'] = listings.firstname & ' ' & listings.surname />
					<cfset dataArray[listings.currentRow]['partner']['firstname'] = listings.firstname />
				<cfelse>
					<cfset dataArray[listings.currentRow]['partner']['name'] = listings.company />
					<cfset dataArray[listings.currentRow]['partner']['firstname'] = listings.company />
				</cfif>


			</cfloop>

			<cfset result['data'] = dataArray />


		<cfset objTools.runtime('post', '/customer/{customerID}/favourites/listings', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
