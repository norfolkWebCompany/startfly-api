<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/bookings/occurrences/{occurrenceID}/cancel" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="customerID" type="string" required="true" />
		<cfargument name="occurrenceID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />
		<cfset result['arguments'] = arguments />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />


		<cfquery name="bookings" datasource="startfly">
		UPDATE bookingDetail SET 
		status = 4,
		cancellationDate = NOW(),
		cancelledBy = 'Customer',
		cancellationReason = #arguments.reason#,
		cancellationReasonText = '#arguments.message#' 
		WHERE customerID = #internalCustomerID# 
		AND sID = '#arguments.bookingID#'
		</cfquery>

		<cfquery name="thisCustomer" datasource="startfly">
		SELECT email 
		FROM customer 
		WHERE ID = #internalCustomerID#
		</cfquery>

		<cfquery name="thisBooking" datasource="startfly">
		SELECT partner.email, listing.name 
		FROM bookingDetail  
		INNER JOIN listing ON bookingDetail.listingID = listing.ID
		INNER JOIN partner ON bookingDetail.partnerID = partner.ID 
		WHERE bookingDetail.sID = '#arguments.bookingID#' 
		</cfquery>

		<cfset messageData = {
			sentFrom = thisCustomer.email,
			sentTo = thisBooking.email,
			type = 4,
			uID = arguments.bookingID,
			folder = 'Inbox',
			subject = 'Booking Cancellation - ' & thisBooking.name,
			content = arguments.message
		} />

		<cfset objEmail = createObject('component','/resources/private/email') />
		<cfset messageResult = objEmail.send(messageData) />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>




</cfcomponent>
