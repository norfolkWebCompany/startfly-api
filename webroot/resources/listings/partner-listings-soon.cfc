<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/listings/soon" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfquery name="listings" datasource="startfly">
		SELECT 
		listingOccurrence.starts,
		listingOccurrence.ends,
		listingOccurrence.sID as occurrenceSID,
		listingOccurrence.cancelled,
		listing.sID as listingSID,
		listing.type,
		listing.name,
		listing.cost,
		listing.capacity,
		listing.location,
		listing.locationType,
		locations.name as locationName,
		locationTypes.name as locationTypeName,
		listingType.name as listingTypeName,
		(SELECT IFNULL(sum(qty),0) FROM bookingDetail WHERE bookingDetail.occurrenceID = listingOccurrence.ID) AS totalBookings
		FROM listingOccurrence 
		LEFT JOIN listing ON listingOccurrence.listingID = listing.ID 
		LEFT JOIN listingType ON listing.type = listingType.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN locationTypes ON listing.locationType = locationTypes.ID
		WHERE listingOccurrence.partnerID = #internalPartnerID# 
		AND listingOccurrence.starts >= #objDates.toEpoch(now())# 
		AND listingOccurrence.starts <= #objDates.toEpoch(dateAdd('d',14,now()))# 
		AND (SELECT IFNULL(sum(qty),0) FROM bookingDetail WHERE bookingDetail.occurrenceID = listingOccurrence.ID) > 0 
		AND listingOccurrence.cancelled = 0
		ORDER BY listingOccurrence.starts
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfif listings.recordCount gt 0>

			<cfloop query="listings">
			
				<cfset dataArray[listings.currentRow]['listingID'] = listings.listingSID />
				<cfset dataArray[listings.currentRow]['occurrenceID'] = listings.occurrenceSID />
				<cfset dataArray[listings.currentRow]['cancelled'] = listings.cancelled />
				<cfset dataArray[listings.currentRow]['name'] = listings.name />
				<cfset dataArray[listings.currentRow]['listingType'] = listings.type />
				<cfset dataArray[listings.currentRow]['listingTypeName'] = listings.listingTypeName />
				<cfset dataArray[listings.currentRow]['locationType'] = listings.locationType />
				<cfset dataArray[listings.currentRow]['locationTypeName'] = listings.locationTypeName />
				<cfset dataArray[listings.currentRow]['location']['locationID'] = listings.location />
				<cfset dataArray[listings.currentRow]['location']['name'] = listings.locationName />
				<cfset dataArray[listings.currentRow]['cost'] = listings.cost />
				<cfset dataArray[listings.currentRow]['capacity'] = listings.capacity />
				<cfset dataArray[listings.currentRow]['startDate'] = objDates.fromEpoch(listings.starts,'JSON') />
				<cfset dataArray[listings.currentRow]['attending'] = listings.totalBookings />

			</cfloop>

			<cfset result['data'] = dataArray />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/partner/{partnerID}/listings/soon', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
