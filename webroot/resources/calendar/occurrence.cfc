<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/calendar/{occurrenceID}" hint="some hint about this resource">
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
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />


		<cfquery name="occurrences" datasource="startfly">
		SELECT 
		listingOccurrence.startDate,
		listingOccurrence.endDate,
		listingOccurrence.ID,
		listingOccurrence.listingID,
		listingOccurrence.partnerID,
		listingOccurrence.startDateID,
		listingOccurrence.startTimeID,
		listingOccurrence.endDateID,
		listingOccurrence.endTimeID,
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
		WHERE listingOccurrence.ID = #internalOccurrenceID#
		AND listingOccurrence.partnerID = #internalPartnerID#
		</cfquery>

		<cfset result['data']['id'] = occurrences.currentRow />
		<cfset result['data']['occurrenceID'] = occurrences.ID />
		<cfset result['data']['listingID'] = occurrences.listingID />
		<cfset result['data']['partnerID'] = occurrences.partnerID />
		<cfset result['data']['location']['name'] = occurrences.locationName />
		<cfset result['data']['location']['add1'] = occurrences.add1 />
		<cfset result['data']['location']['add2'] = occurrences.add2 />
		<cfset result['data']['location']['add3'] = occurrences.add3 />
		<cfset result['data']['location']['town'] = occurrences.town />
		<cfset result['data']['location']['postcode'] = occurrences.postcode />
		<cfset result['data']['systemStart']['date'] = dateFormat(occurrences.startDate, "yyyy-mm-dd") & 'T' & timeFormat(occurrences.startDate,"HH:mm:ss") & 'Z' />
		<cfset result['data']['systemStart']['theHour'] = timeFormat(occurrences.startDate,"HH") />
		<cfset result['data']['systemStart']['theMins'] = timeFormat(occurrences.startDate,"mm") />

		<cfset result['data']['systemEnd']['date'] = dateFormat(occurrences.endDate, "yyyy-mm-dd") & 'T' & timeFormat(occurrences.endDate,"HH:mm:ss") & 'Z' />
		<cfset result['data']['systemEnd']['theHour'] = timeFormat(occurrences.endDate,"HH") />
		<cfset result['data']['systemEnd']['theMins'] = timeFormat(occurrences.endDate,"mm") />



		<cfset result['data']['title'] = occurrences.name />
		<cfset result['data']['listingType'] = occurrences.type />
<!--- 		<cfset result['data']['start'] = dateFormat(occurrences.startDate, "ddd mmm dd yyyy") & ' ' & timeFormat(occurrences.startDate,"HH:mm:ss") & ' GMT+0000 (GMT)' />
		<cfset result['data']['end'] = dateFormat(occurrences.endDate, "ddd mmm dd yyyy") & ' ' & timeFormat(occurrences.endDate,"HH:mm:ss") & ' GMT+0000 (GMT)' />
 --->
		<cfset result['data']['start'] = objDates.fromEpoch(occurrences.starts,'JSON') />
		<cfset result['data']['end'] = objDates.fromEpoch(occurrences.ends,'JSON') />

		<cfset result['data']['listColor'] = 'danger' />
		<cfset result['data']['className'] = 'event-danger' />
		<cfset result['data']['stick'] = true />


		<cfset objTools.runtime('post', '/partner/{partnerID}/calendar/{occurrenceID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
