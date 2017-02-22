<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/bookings/{bookingID}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="bookingID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objAccum = createObject('component','/resources/private/accum') />


        <cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
        <cfset internalBookingID = objTools.internalID('bookings',arguments.bookingID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset data = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="bookings" datasource="startfly">
		SELECT 
		listing.ID AS internalListingID,
		listing.sID AS listingID,
		listing.name as listingName,
		listingType.name AS listingTypeName,
		listing.location,
		bookings.sID AS bookingID,
		bookings.customerID,
		bookings.created,
		bookings.totalPaid,
		bookings.gross,
		bookings.net,
		bookings.vat,
		bookings.status,
		bookingStatus.name as statusName, 
		customer.firstname,
		customer.surname,
		customer.bio,
		customer.avatar,
		customer.dob,
		customer.gender,
		locations.name as locationName,
		locations.add1,
		locations.add2,
		locations.town 
		FROM bookings 
		INNER JOIN listing ON bookings.listingID = listing.ID 
		LEFT JOIN locations ON listing.location = locations.ID
		INNER JOIN listingType ON listing.type = listingType.ID
		INNER JOIN bookingStatus on bookings.status = bookingStatus.ID 
		INNER JOIN customer ON bookings.customerID = customer.ID 
		WHERE bookings.partnerID = #internalPartnerID# 
		AND bookings.ID = #internalBookingID#
		</cfquery>



			<cfset result['data']['bookingID'] = bookings.bookingID />
			<cfset result['data']['customer']['firstname'] = bookings.firstname />
			<cfset result['data']['customer']['surname'] = bookings.surname />
			<cfset result['data']['location']['name'] = bookings.locationName />
			<cfset result['data']['location']['address1'] = bookings.add1 />
			<cfset result['data']['location']['address2'] = bookings.add2 />
			<cfset result['data']['location']['town'] = bookings.town />
			<cfset result['data']['customer']['gender'] = bookings.gender />
			<cfset result['data']['customer']['bio'] = bookings.bio />
			<cfset result['data']['customer']['imageURL'] = bookings.avatar />

			<cfset result['data']['listing']['name'] = bookings.listingName />
			<cfset result['data']['listing']['type'] = bookings.listingTypeName />
			<cfset result['data']['totalPaid'] = bookings.totalPaid />
			<cfset result['data']['created'] = dateFormat(bookings.created, "yyyy-mm-dd") & 'T' & timeFormat(bookings.created,"HH:mm:ss") & 'Z' />

		<cfquery name="occurrences" datasource="startfly">
		SELECT 
		bookingDetail.sID,
		bookingDetail.startDateID,
		bookingDetail.startTimeID,
		bookingDetail.endDateID,
		bookingDetail.endTimeID
		FROM bookingDetail 
		WHERE bookingID = #internalBookingID# 
		ORDER BY bookingDetail.startDateID
		</cfquery>

		<cfset occurrencesArray = arrayNew(1) />

		<cfloop query="occurrences">
			<cfset occurrencesArray[occurrences.currentRow]['starts'] = objDates.getDim(occurrences.startDateID,occurrences.startTimeID,'JSON') /> />
			<cfset occurrencesArray[occurrences.currentRow]['ends'] = objDates.getDim(occurrences.endDateID,occurrences.endTimeID,'JSON') /> />
		</cfloop>

		<cfset result['data']['occurrences'] = occurrencesArray />


		<cfset historyArray = arrayNew(1) />
		<cfset ha = 0 />

		<cfset ha = ha + 1 />
		<cfset historyArray[ha]['name'] = 'Booking Created' />
		<cfset historyArray[ha]['created'] = dateFormat(bookings.created, "yyyy-mm-dd") & 'T' & timeFormat(bookings.created,"HH:mm:ss") & 'Z' />
		<cfset historyArray[ha]['comments'] = '' />


		<cfquery name="confirmation" datasource="startfly">
		SELECT 
		bookingConfirmation.created,
		bookingConfirmation.status,
		bookingConfirmation.comments 
		FROM bookingConfirmation 
		WHERE bookingID = #internalBookingID# 
		ORDER BY created
		</cfquery>

		<cfloop query="confirmation">
			<cfset ha = ha + 1 />
			<cfswitch expression="#confirmation.status#">
				<cfcase value="2">
					<cfset historyArray[ha]['name'] = 'Booking Accepted' />
				</cfcase>
				<cfcase value="3">
					<cfset historyArray[ha]['name'] = 'Booking Declined' />
				</cfcase>
			</cfswitch>
			<cfset historyArray[ha]['created'] = dateFormat(confirmation.created, "yyyy-mm-dd") & 'T' & timeFormat(confirmation.created,"HH:mm:ss") & 'Z' />
			<cfset historyArray[ha]['comments'] = confirmation.comments />

		</cfloop>

		<cfset result['data']['history'] = historyArray />

			<cfset objTools.runtime('post', '/partner/{partnerID}/bookings/{bookingID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
