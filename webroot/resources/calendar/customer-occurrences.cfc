<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/calendar" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />


		<cfquery name="occurrences" datasource="startfly">
		SELECT 
		bookingDetail.startDateID,
		bookingDetail.startTimeID,
		bookingDetail.endDateID,
		bookingDetail.endTimeID,
		bookingDetail.sID AS bookingSID,
		bookingDetail.partnerID,
		bookingDetail.status,
		bookingStatus.name as statusName,
		listing.sID as listingSID,
		listing.name,
		listing.type,
		locations.name as locationName,
		locations.add1, 
		locations.add2, 
		locations.add3, 
		locations.town,
		locations.postcode 
		FROM bookingDetail 
		INNER JOIN listing ON bookingDetail.listingID = listing.ID 
		LEFT JOIN locations ON listing.location = locations.ID
		LEFT JOIN bookingStatus on bookingDetail.status = bookingStatus.ID 
		WHERE bookingDetail.customerID = #internalCustomerID# 
		ORDER BY bookingDetail.sessionDateID
		</cfquery>

		<cfset dataArray = arrayNew(1) />

			<cfloop query="occurrences">

				<cfset dataArray[occurrences.currentRow]['id'] = occurrences.currentRow />
				<cfset dataArray[occurrences.currentRow]['bookingID'] = occurrences.bookingSID />
				<cfset dataArray[occurrences.currentRow]['listingID'] = occurrences.listingsID />
				<cfset dataArray[occurrences.currentRow]['partnerID'] = occurrences.partnerID />
				<cfset dataArray[occurrences.currentRow]['location']['name'] = occurrences.locationName />
				<cfset dataArray[occurrences.currentRow]['location']['add1'] = occurrences.add1 />
				<cfset dataArray[occurrences.currentRow]['location']['add2'] = occurrences.add2 />
				<cfset dataArray[occurrences.currentRow]['location']['add3'] = occurrences.add3 />
				<cfset dataArray[occurrences.currentRow]['location']['town'] = occurrences.town />
				<cfset dataArray[occurrences.currentRow]['location']['postcode'] = occurrences.postcode />


				<cfset dataArray[occurrences.currentRow]['title'] = occurrences.name />
				<cfset dataArray[occurrences.currentRow]['listingType'] = occurrences.type />
				<cfset dataArray[occurrences.currentRow]['start'] = objDates.getDim(occurrences.startDateID,occurrences.startTimeID,'JSON') /> />
				<cfset dataArray[occurrences.currentRow]['end'] = objDates.getDim(occurrences.endDateID,occurrences.endTimeID,'JSON') /> />

				<cfset dataArray[occurrences.currentRow]['status'] = occurrences.statusName />
				<cfswitch expression="occurrences.status">
					<cfcase value="1">
						<cfset dataArray[occurrences.currentRow]['listColor'] = 'warning' />
						<cfset dataArray[occurrences.currentRow]['className'] = 'event-warning' />
					</cfcase>
					<cfcase value="2">
						<cfset dataArray[occurrences.currentRow]['listColor'] = 'success' />
						<cfset dataArray[occurrences.currentRow]['className'] = 'event-success' />
					</cfcase>
					<cfcase value="5">
						<cfset dataArray[occurrences.currentRow]['listColor'] = 'success' />
						<cfset dataArray[occurrences.currentRow]['className'] = 'event-success' />
					</cfcase>
					<cfdefaultcase>
						<cfset dataArray[occurrences.currentRow]['listColor'] = 'danger' />
						<cfset dataArray[occurrences.currentRow]['className'] = 'event-danger' />
					</cfdefaultcase>
				</cfswitch>
				<cfset dataArray[occurrences.currentRow]['stick'] = true />


			</cfloop>


		<cfset objTools.runtime('post', 'customer/{customerID}/calendar', (getTickCount() - sTime) ) />

		<cfreturn representationOf(dataArray).withStatus(200) />

	</cffunction>


</cfcomponent>
