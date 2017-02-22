<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/listings" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="listings" datasource="startfly">
		SELECT 
		listing.ID,
		listing.sID,
		listing.type,
		listing.name,
		listing.cost,
		listing.rating,
		listing.featured,
		listing.imageURL,
		listing.previewText,
		listing.ageMin,
		listing.ageMax,
		listing.created,
		listing.capacity,
		listing.location,
		listing.locationType,
		listing.maxTravelMiles,
		listing.travelFee,
		listing.travelFeePerMile,
		locations.name as locationName,
		locationTypes.name as locationTypeName,
		listingType.name as listingTypeName,
		(SELECT IFNULL(SUM(net),0) FROM bookings WHERE listingID = listing.ID) as totalSales
		FROM listing 
		INNER JOIN listingType ON listing.type = listingType.ID 
		INNER JOIN locationTypes ON listing.locationType = locationTypes.ID
		LEFT JOIN locations ON listing.location = locations.ID 
		WHERE listing.partnerID = #internalPartnerID# 
		AND listing.deleted = 0
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfif listings.recordCount gt 0>
			

			<cfloop query="listings">

				<cfquery name="categories" datasource="startfly">
				SELECT 
				courseCategory.name,
				courseCategory.URL,
				courseCategory.secureID 
				FROM listingCategory 
				INNER JOIN courseCategory ON listingCategory.categoryID = courseCategory.ID 
				WHERE listingCategory.listingID = #listings.ID# 
				</cfquery>
				
				<cfset dataArray[listings.currentRow]['listingID'] = listings.sID />
				<cfset dataArray[listings.currentRow]['name'] = listings.name />
				<cfset dataArray[listings.currentRow]['listingType'] = listings.type />
				<cfset dataArray[listings.currentRow]['listingTypeName'] = listings.listingTypeName />
				<cfset dataArray[listings.currentRow]['locationType'] = listings.locationType />
				<cfset dataArray[listings.currentRow]['locationTypeName'] = listings.locationTypeName />
				<cfset dataArray[listings.currentRow]['maxTravelMiles'] = listings.maxTravelMiles />
				<cfset dataArray[listings.currentRow]['travelFee'] = listings.travelFee />
				<cfset dataArray[listings.currentRow]['travelFeePerMile'] = listings.travelFeePerMile />
				<cfset dataArray[listings.currentRow]['ageMin'] = listings.ageMin />
				<cfset dataArray[listings.currentRow]['ageMax'] = listings.ageMax />
				<cfset dataArray[listings.currentRow]['location']['locationID'] = listings.location />
				<cfset dataArray[listings.currentRow]['location']['name'] = listings.locationName />
				<cfset dataArray[listings.currentRow]['cost'] = listings.cost />
				<cfset dataArray[listings.currentRow]['rating'] = listings.rating />
				<cfset dataArray[listings.currentRow]['totalSales'] = listings.totalSales />
				<cfset dataArray[listings.currentRow]['capacity'] = listings.capacity />
				<cfset dataArray[listings.currentRow]['featured'] = listings.featured />
				<cfset dataArray[listings.currentRow]['imageURL'] = listings.imageURL />
				<cfset dataArray[listings.currentRow]['previewText'] = listings.previewText />
				<cfset dataArray[listings.currentRow]['created'] = dateFormat(listings.created, "yyyy-mm-dd") & 'T' & timeFormat(listings.created,"HH:mm:ss") & 'Z' />

				<cfset dataArray[listings.currentRow]['categories'] = arrayNew(1) />

				<cfloop query="categories">
					<cfset  dataArray[listings.currentRow]['categories'][categories.currentRow]['categoryID'] = categories.secureID />
					<cfset  dataArray[listings.currentRow]['categories'][categories.currentRow]['pageURL'] = categories.URL />
					<cfset  dataArray[listings.currentRow]['categories'][categories.currentRow]['categoryName'] = categories.name />
				</cfloop>


			</cfloop>

			<cfset result['data'] = dataArray />

		<cfelse>
			<cfset result['data'] = [] />
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/partner/{partnerID}/listings', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
