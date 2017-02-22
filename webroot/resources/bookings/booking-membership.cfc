<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/bookingsMembership/{bookingID}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="bookingID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objAccum = createObject('component','/resources/private/accum') />


        <cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
        <cfset internalBookingID = objTools.internalID('membershipBooking',arguments.bookingID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset data = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

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
		membershipBooking.paymentPlan,
		bookingStatus.name as statusName, 
		customer.firstname,
		customer.surname,
		customer.bio,
		customer.avatar,
		customer.dob,
		customer.gender
		FROM membershipBooking 
		INNER JOIN memberships ON membershipBooking.membershipID = memberships.ID 
		INNER JOIN bookingStatus on membershipBooking.status = bookingStatus.ID 
		INNER JOIN customer ON membershipBooking.customerID = customer.ID 
		WHERE membershipBooking.partnerID = #internalPartnerID#
		AND membershipBooking.ID = #internalBookingID#
		</cfquery>



			<cfset result['data']['bookingID'] = bookings.bookingID />
			<cfset result['data']['customer']['firstname'] = bookings.firstname />
			<cfset result['data']['customer']['surname'] = bookings.surname />
			<cfset result['data']['customer']['gender'] = bookings.gender />
			<cfset result['data']['customer']['bio'] = bookings.bio />
			<cfset result['data']['customer']['imageURL'] = bookings.avatar />

			<cfset result['data']['membership']['name'] = bookings.membershipName />
			<cfset result['data']['totalPaid'] = bookings.totalPaid />
			<cfset result['data']['created'] = dateFormat(bookings.created, "yyyy-mm-dd") & 'T' & timeFormat(bookings.created,"HH:mm:ss") & 'Z' />

			<cfquery name="paymentPlan" datasource="startfly">
			SELECT 
			paymentPlan.installment,
			paymentPlan.paid,
			paymentPlan.amount,
			paymentPlan.paymentDate 
			FROM paymentPlan 
			WHERE paymentPlan.paymentPlanID = #bookings.paymentPlan# 
			ORDER BY installment
			</cfquery>

			<cfif paymentPlan.recordCount gt 0>
				<cfset planArray = arrayNew(1) />

				<cfloop query="paymentPlan">
					<cfset planArray[paymentPlan.currentRow]['installment'] = paymentPlan.installment />
					<cfset planArray[paymentPlan.currentRow]['paid'] = paymentPlan.paid />
					<cfset planArray[paymentPlan.currentRow]['amount'] = paymentPlan.amount />
					<cfset planArray[paymentPlan.currentRow]['paymentDate'] = dateFormat(paymentPlan.paymentDate, "yyyy-mm-dd") />
				</cfloop>
				<cfset result['data']['paymentPlan'] = planArray />
			</cfif>

		<cfset historyArray = arrayNew(1) />
		<cfset ha = 0 />

		<cfset ha = ha + 1 />
		<cfset historyArray[ha]['name'] = 'Membership Purchased' />
		<cfset historyArray[ha]['created'] = dateFormat(bookings.created, "yyyy-mm-dd") & 'T' & timeFormat(bookings.created,"HH:mm:ss") & 'Z' />
		<cfset historyArray[ha]['comments'] = '' />


		<cfset result['data']['history'] = historyArray />

		<cfset result['args'] = arguments />
			<cfset objTools.runtime('post', '/partner/{partnerID}/bookingsMembership/{bookingID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
