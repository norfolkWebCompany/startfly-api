<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/calendar" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />


		<cfquery name="occurrences" datasource="startfly">
		SELECT 
		listingOccurrence.starts,
		listingOccurrence.ends,
		listingOccurrence.sID AS occurrenceSID,
		listingOccurrence.partnerID,
		listing.sID as listingSID,
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
		WHERE listingOccurrence.partnerID = #internalPartnerID# 
		AND listingOccurrence.archive = 0 
		AND listing.deleted = 0
		ORDER BY listingOccurrence.starts
		</cfquery>

		<cfset dataArray = arrayNew(1) />

			<cfloop query="occurrences">

				<cfset starts = objDates.fromEpoch(occurrences.starts) />
				<cfset ends = objDates.fromEpoch(occurrences.ends) />

				<cfset dataArray[occurrences.currentRow]['id'] = occurrences.currentRow />
				<cfset dataArray[occurrences.currentRow]['occurrenceID'] = occurrences.occurrenceSID />
				<cfset dataArray[occurrences.currentRow]['listingID'] = occurrences.listingsID />
				<cfset dataArray[occurrences.currentRow]['partnerID'] = arguments.partnerID />
				<cfset dataArray[occurrences.currentRow]['location']['name'] = occurrences.locationName />
				<cfset dataArray[occurrences.currentRow]['location']['add1'] = occurrences.add1 />
				<cfset dataArray[occurrences.currentRow]['location']['add2'] = occurrences.add2 />
				<cfset dataArray[occurrences.currentRow]['location']['add3'] = occurrences.add3 />
				<cfset dataArray[occurrences.currentRow]['location']['town'] = occurrences.town />
				<cfset dataArray[occurrences.currentRow]['location']['postcode'] = occurrences.postcode />


				<cfset dataArray[occurrences.currentRow]['title'] = occurrences.name />
				<cfset dataArray[occurrences.currentRow]['listingType'] = occurrences.type />
				<!---
				<cfset dataArray[occurrences.currentRow]['start'] = dateFormat(occurrences.startDate, "ddd mmm dd yyyy") & ' ' & timeFormat(occurrences.startDate,"HH:mm:ss") & ' GMT+0000 (GMT)' />
				<cfset dataArray[occurrences.currentRow]['end'] = dateFormat(occurrences.endDate, "ddd mmm dd yyyy") & ' ' & timeFormat(occurrences.endDate,"HH:mm:ss") & ' GMT+0000 (GMT)' />
				--->
				<cfset dataArray[occurrences.currentRow]['start'] = objDates.fromEpoch(occurrences.starts,'JSON') />
				<cfset dataArray[occurrences.currentRow]['end'] = objDates.fromEpoch(occurrences.ends,'JSON') />

				<cfset dataArray[occurrences.currentRow]['listColor'] = 'danger' />
				<cfset dataArray[occurrences.currentRow]['className'] = 'event-danger' />
				<cfset dataArray[occurrences.currentRow]['stick'] = true />


			</cfloop>


		<cfset objTools.runtime('post', 'partner/{partnerID}/calendar', (getTickCount() - sTime) ) />

		<cfreturn representationOf(dataArray).withStatus(200) />

	</cffunction>


</cfcomponent>
