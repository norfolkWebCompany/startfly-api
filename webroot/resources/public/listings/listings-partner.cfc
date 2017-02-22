<cfcomponent extends="taffy.core.resource" taffy:uri="/public/partner/{partnerID}/listings" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="type" type="numeric" required="false" default="0" />

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />


		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset sDate = objDates.toEpoch(now()) />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset dataArray = arrayNew(1) />


		<cfquery name="occurrences" datasource="startfly" result="oc">
		SELECT 
		listingOccurrence.listingID 
		FROM listingOccurrence 
		WHERE starts > #sDate# 
		AND partnerID = #internalPartnerID#
		GROUP BY listingID
		</cfquery>

		<cfquery name="listings" datasource="startfly">
		SELECT 
		listing.sID AS listingID,
		listing.name,
		listing.url,
		listing.imageURL,
		listing.location,
		listing.cost,
		listing.capacity,
		listing.featured,
		listing.previewText,
		listing.paymentPlan,
		listing.created,
		listing.howOften,
		listing.type,
		listing.locationType,
		listing.maxTravelMiles,
		locations.sID as locationSID,
		locations.name AS locationName,
		locations.longitude,
		locations.latitude,
		locations.add1,
		locations.add2,
		locations.add3,
		locations.town,
		locations.county,
		locations.country,
		locations.postcode,
		locations.hideAddress,
		listingType.name as typeName
		FROM listing 
		INNER JOIN listingCategory ON listing.ID = listingCategory.listingID 
		INNER JOIN courseCategory ON listingCategory.categoryID = courseCategory.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN listingType ON listing.type = listingType.ID
		WHERE listing.status = 1 
		AND listing.deleted = 0 
		AND listing.partnerID = #internalPartnerID#
		<cfif occurrences.recordCount gt 0>
        AND (
        	listing.ID IN (#valueList(occurrences.listingID)#) 
        	OR 
        	listing.workingHours > 0
        	)
		<cfelse>
		AND listing.workingHours > 0
		</cfif>
		ORDER BY listing.name 
		</cfquery>



		<cfloop query="listings">
			
			<cfset dataArray[listings.currentRow]['listingID'] = listings.listingID />
			<cfset dataArray[listings.currentRow]['name'] = listings.name />
			<cfset dataArray[listings.currentRow]['url'] = listings.url />
			<cfset dataArray[listings.currentRow]['type'] = listings.type />
			<cfset dataArray[listings.currentRow]['typeName'] = listings.typeName />
			<cfset dataArray[listings.currentRow]['cost'] = listings.cost />
			<cfset dataArray[listings.currentRow]['capacity'] = listings.capacity />
			<cfset dataArray[listings.currentRow]['featured'] = listings.featured />
			<cfset dataArray[listings.currentRow]['imageURL'] = listings.imageURL />
			<cfset dataArray[listings.currentRow]['previewText'] = listings.previewText />
			<cfset dataArray[listings.currentRow]['created'] = objDates.fromEpoch(listings.created,'JSON') />
			<cfset dataArray[listings.currentRow]['locationType'] = listings.locationType />
			<cfset dataArray[listings.currentRow]['maxTravelMiles'] = listings.maxTravelMiles />

			<cfset dataArray[listings.currentRow]['location']['locationID'] = listings.location />
			<cfset dataArray[listings.currentRow]['location']['name'] = listings.locationName />
			<cfset dataArray[listings.currentRow]['location']['address1'] = listings.add1 />
			<cfset dataArray[listings.currentRow]['location']['address2'] = listings.add2 />
			<cfset dataArray[listings.currentRow]['location']['address3'] = listings.add3 />
			<cfset dataArray[listings.currentRow]['location']['town'] = listings.town />
			<cfset dataArray[listings.currentRow]['location']['county'] = listings.county />
			<cfset dataArray[listings.currentRow]['location']['country'] = listings.country />
			<cfset dataArray[listings.currentRow]['location']['postcode'] = listings.postcode />
			<cfset dataArray[listings.currentRow]['location']['hideAddress'] = listings.hideAddress />
			<cfset dataArray[listings.currentRow]['location']['longitude'] = listings.longitude />
			<cfset dataArray[listings.currentRow]['location']['latitude'] = listings.latitude />

			<cfset dataArray[listings.currentRow]['categories'] = arrayNew(1) />

			<cfquery name="categories" datasource="startfly">
			SELECT 
			courseCategory.name,
			courseCategory.URL,
			courseCategory.secureID 
			FROM listingCategory 
			INNER JOIN courseCategory ON listingCategory.categoryID = courseCategory.ID 
			WHERE listingCategory.listingID = '#listings.listingID#' 
			</cfquery>


			<cfloop query="categories">
				<cfset  dataArray[listings.currentRow]['categories'][categories.currentRow]['categoryID'] = categories.secureID />
				<cfset  dataArray[listings.currentRow]['categories'][categories.currentRow]['pageURL'] = categories.URL />
				<cfset  dataArray[listings.currentRow]['categories'][categories.currentRow]['categoryName'] = categories.name />
			</cfloop>


		</cfloop>

		<cfset result['data'] = dataArray />

		<cfset result['arguments'] = arguments />

		<cfset objTools.runtime('get', '/public/partner/listings', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
