<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/calendar/{occurrenceID}/{listingID}/other" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalOccurrenceID = objTools.internalID('listingOccurrence',arguments.occurrenceID) />
		<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfquery name="occurrences" datasource="startfly">
		SELECT 
		listingOccurrence.starts,
		listingOccurrence.ends,
		listingOccurrence.ID,
		listingOccurrence.sID,
		listingOccurrence.startDateID,
		listingOccurrence.startTimeID,
		listingOccurrence.endDateID,
		listingOccurrence.endTimeID,
		listingOccurrence.listingID,
		listingOccurrence.partnerID,
		listing.name,
		listing.type,
		locations.name as locationName,
		locations.add1, 
		locations.add2, 
		locations.add3, 
		locations.town,
		locations.postcode 
		FROM listingOccurrence 
		INNER JOIN listing ON listingOccurrence.listingID = listing.ID 
		LEFT JOIN locations ON listing.location = locations.ID
		WHERE listing.ID = #internalListingID#
		AND listingOccurrence.ID > #internalOccurrenceID# 
		AND listingOccurrence.partnerID = #internalPartnerID#
		ORDER BY listingOccurrence.starts
		</cfquery>

		<cfset dataArray = arrayNew(1) />

			<cfloop query="occurrences">

				<cfset starts = objDates.fromEpoch(occurrences.starts) />
				<cfset ends = objDates.fromEpoch(occurrences.ends) />

				<cfset dataArray[occurrences.currentRow]['id'] = occurrences.currentRow />
				<cfset dataArray[occurrences.currentRow]['occurrenceID'] = occurrences.sID />
				<cfset dataArray[occurrences.currentRow]['listingID'] = occurrences.listingID />
				<cfset dataArray[occurrences.currentRow]['partnerID'] = occurrences.partnerID />
				<cfset dataArray[occurrences.currentRow]['location']['name'] = occurrences.locationName />
				<cfset dataArray[occurrences.currentRow]['location']['add1'] = occurrences.add1 />
				<cfset dataArray[occurrences.currentRow]['location']['add2'] = occurrences.add2 />
				<cfset dataArray[occurrences.currentRow]['location']['add3'] = occurrences.add3 />
				<cfset dataArray[occurrences.currentRow]['location']['town'] = occurrences.town />
				<cfset dataArray[occurrences.currentRow]['location']['postcode'] = occurrences.postcode />
				<cfset dataArray[occurrences.currentRow]['title'] = occurrences.name />
				<cfset dataArray[occurrences.currentRow]['listingType'] = occurrences.type />

<!--- 				<cfset dataArray[occurrences.currentRow]['start'] = dateFormat(occurrences.startDate, "ddd mmm dd yyyy") & ' ' & timeFormat(occurrences.startDate,"HH:mm:ss") & ' GMT+0000 (GMT)' />
				<cfset dataArray[occurrences.currentRow]['end'] = dateFormat(occurrences.endDate, "ddd mmm dd yyyy") & ' ' & timeFormat(occurrences.endDate,"HH:mm:ss") & ' GMT+0000 (GMT)' />
 --->

				<cfset dataArray[occurrences.currentRow]['start'] = objDates.getDim(occurrences.startDateID,occurrences.startTimeID,'JSON') />
				<cfset dataArray[occurrences.currentRow]['end'] = objDates.getDim(occurrences.endDateID,occurrences.endTimeID,'JSON') />

				<cfset dataArray[occurrences.currentRow]['listColor'] = 'danger' />
				<cfset dataArray[occurrences.currentRow]['className'] = 'event-danger' />
				<cfset dataArray[occurrences.currentRow]['stick'] = true />

			</cfloop>

		<cfset result['data'] = dataArray />

		<cfset objTools.runtime('post', '/partner/{partnerID}/calendar/{occurrenceID}/{listingID}/other', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
