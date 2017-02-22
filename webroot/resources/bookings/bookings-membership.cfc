<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/bookingsMembership" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objAccum = createObject('component','/resources/private/accum') />


        <cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />


		<cfquery name="bookings" datasource="startfly">
		SELECT 
		memberships.sID AS membershipID,
		memberships.name as membershipName,
		membershipBooking.sID AS bookingID,
		membershipBooking.customerID,
		membershipBooking.created,
		membershipBooking.totalPaid,
		membershipBooking.gross,
		membershipBooking.net,
		membershipBooking.vat,
		membershipBooking.status,
		bookingStatus.name as statusName, 
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
		customer.gender
		FROM membershipBooking 
		INNER JOIN memberships ON membershipBooking.membershipID = memberships.ID 
		INNER JOIN bookingStatus on membershipBooking.status = bookingStatus.ID 
		INNER JOIN customer ON membershipBooking.customerID = customer.ID 
		WHERE membershipBooking.partnerID = #internalPartnerID#
		ORDER BY membershipBooking.created DESC 
		</cfquery>


			<cfset dataArray = arrayNew(1) />


				<cfloop query="bookings">
					
		
					<cfset dataArray[bookings.currentRow]['bookingID'] = bookings.bookingID />
					<cfset dataArray[bookings.currentRow]['membershipID'] = bookings.membershipID />
					<cfset dataArray[bookings.currentRow]['firstname'] = bookings.firstname />
					<cfset dataArray[bookings.currentRow]['surname'] = bookings.surname />
					<cfset dataArray[bookings.currentRow]['gender'] = bookings.gender />
					<cfset dataArray[bookings.currentRow]['age'] = dateDiff('yyyy',bookings.dob,now()) />


					<cfset dataArray[bookings.currentRow]['membershipName'] = bookings.membershipName />
					<cfset dataArray[bookings.currentRow]['totalPaid'] = bookings.totalPaid />
					<cfset dataArray[bookings.currentRow]['status']['ID'] = bookings.status />
					<cfset dataArray[bookings.currentRow]['status']['description'] = bookings.statusName />
					<cfset dataArray[bookings.currentRow]['created'] = dateFormat(bookings.created, "yyyy-mm-dd") & 'T' & timeFormat(bookings.created,"HH:mm:ss") & 'Z' />

				</cfloop>

				<cfset result['data'] = dataArray />

			<cfset objTools.runtime('post', '/partner/{partnerID}/bookingsMembership', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
