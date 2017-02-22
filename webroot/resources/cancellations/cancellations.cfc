<cfcomponent extends="taffy.core.resource" taffy:uri="/cancellations" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="false" default="" />
		<cfargument name="customerID" type="string" required="false" default="" />
		<cfargument name="customer" type="string" required="false" default="" />
		<cfargument name="listingName" type="string" required="false" default="" />
		<cfargument name="reason" type="numeric" required="false" default="0" />
		<cfargument name="cancelledBy" type="string" required="false" default="" />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

        <cfif arguments.partnerID neq ''>
	        <cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
        </cfif>

        <cfif arguments.customerID neq ''>
	        <cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
        </cfif>


		<cfquery name="bookings" datasource="startfly">
		SELECT 
		listing.sID AS listingID,
		listing.name as listingName,
		bookingDetail.sID AS bookingID,
		bookingDetail.created,
		bookingDetail.customerID,
		bookingDetail.created,
		bookingDetail.cancellationDate,
		bookingDetail.cancellationReason,
		bookingDetail.cancellationReasonText,
		bookingDetail.cancelledBy,
		bookingDetail.created,
		cancellationReason.name as cancellationReasonDescription,
		bookingDetail.status,
		bookingStatus.name AS statusName,
		customer.firstname,
		customer.surname,
		customer.add1,
		customer.add2,
		customer.add3,
		customer.town,
		customer.county,
		customer.country,
		customer.postcode,
		customer.dob,
		customer.gender,
		locations.name as locationName,
		locations.town as locationTown,
		locations.postcode as locationPostcode,
		sd.date as startDate,
		st.theHour as startHour,
		st.theMinute as startMinute,  
		ed.date as endDate,
		et.theHour as endHour,
		et.theMinute as endMinute
		FROM bookingDetail 
		INNER JOIN cancellationReason ON bookingDetail.cancellationReason = cancellationReason.ID
		INNER JOIN dimDate sd on bookingDetail.startDateID = sd.dateID
		INNER JOIN dimTime st on bookingDetail.startTimeID = st.timeID
		INNER JOIN dimDate ed on bookingDetail.endDateID = ed.dateID
		INNER JOIN dimTime et on bookingDetail.endTimeID = et.timeID
		INNER JOIN listing ON bookingDetail.listingID = listing.ID 
		INNER JOIN bookingStatus on bookingDetail.status = bookingStatus.ID 
		INNER JOIN customer ON bookingDetail.customerID = customer.ID 
		LEFT JOIN locations ON listing.location = locations.ID
		WHERE bookingDetail.cancelled = 1
        <cfif arguments.partnerID neq ''>
        AND bookingDetail.partnerID = #internalPartnerID#
        </cfif>
        <cfif arguments.customerID neq ''>
        AND bookingDetail.customerID = #internalCustomerID#
        </cfif>
        <cfif arguments.reason neq 0>
        AND bookingDetail.cancellationReason = #arguments.reason#
        </cfif>
        <cfif arguments.cancelledBy neq ''>
        AND bookingDetail.cancelledBy = '#arguments.cancelledBy#'
        </cfif>
        <cfif arguments.customer neq ''>
        AND CONCAT(customer.firstname,' ',customer.surname) LIKE '%#arguments.customer#%'
        </cfif>
        <cfif arguments.listingName neq ''>
        AND listing.name LIKE '%#arguments.listingName#%'
        </cfif>
		ORDER BY bookingDetail.cancellationDate DESC 
		</cfquery>


			<cfset dataArray = arrayNew(1) />


				<cfloop query="bookings">
					
					<cfset cancelledWithin = dateDiff('h',bookings.created,bookings.cancellationDate) />
		
					<cfset dataArray[bookings.currentRow]['bookingID'] = bookings.bookingID />
					<cfset dataArray[bookings.currentRow]['listingID'] = bookings.listingID />
					<cfset dataArray[bookings.currentRow]['listingName'] = bookings.listingName />
					<cfset dataArray[bookings.currentRow]['startDate'] = dateFormat(bookings.startDate,"yyyy-mm-dd") & 'T' & numberFormat(bookings.startHour,"00") &':'& numberFormat(bookings.startMinute,"00") &':00Z' />
					<cfset dataArray[bookings.currentRow]['endDate'] = dateFormat(bookings.endDate,"yyyy-mm-dd") & 'T' & numberFormat(bookings.endHour,"00") &':'& numberFormat(bookings.endMinute,"00") &':00Z' />

					<cfset dataArray[bookings.currentRow]['customer']['firstname'] = bookings.firstname />
					<cfset dataArray[bookings.currentRow]['customer']['surname'] = bookings.surname />

					<cfset dataArray[bookings.currentRow]['cancellation']['date'] = dateFormat(bookings.cancellationDate, "yyyy-mm-dd") & 'T' & timeFormat(bookings.cancellationDate,"HH:mm:ss") & 'Z' />
					<cfset dataArray[bookings.currentRow]['cancellation']['cancelledWithin'] = cancelledWithin />
					<cfset dataArray[bookings.currentRow]['cancellation']['reasonID'] = bookings.cancellationReason />
					<cfset dataArray[bookings.currentRow]['cancellation']['cancelledBy'] = bookings.cancelledBy />
					<cfset dataArray[bookings.currentRow]['cancellation']['reasonDescription'] = bookings.cancellationReasonDescription />
					<cfset dataArray[bookings.currentRow]['cancellation']['reasonText'] = bookings.cancellationReasonText />

					<cfset dataArray[bookings.currentRow]['status']['ID'] = bookings.status />
					<cfset dataArray[bookings.currentRow]['status']['description'] = bookings.statusName />
					<cfset dataArray[bookings.currentRow]['created'] = dateFormat(bookings.created, "yyyy-mm-dd") & 'T' & timeFormat(bookings.created,"HH:mm:ss") & 'Z' />

					<cfset dataArray[bookings.currentRow]['location']['name'] = bookings.locationName />
					<cfset dataArray[bookings.currentRow]['location']['town'] = bookings.locationTown />
					<cfset dataArray[bookings.currentRow]['location']['postcode'] = bookings.locationPostcode />

				</cfloop>

				<cfset result['data'] = dataArray />

			<cfset objTools.runtime('post', '/cancellations', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
