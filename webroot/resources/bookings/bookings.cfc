<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/bookings" hint="some hint about this resource">

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
		listing.sID AS listingID,
		listing.name as listingName,
		listing.howOften,
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
		customer.add1,
		customer.add2,
		customer.add3,
		customer.town,
		customer.county,
		customer.country,
		customer.postcode,
		customer.dob,
		customer.gender
		FROM bookings 
		INNER JOIN listing ON bookings.listingID = listing.ID 
		INNER JOIN bookingStatus on bookings.status = bookingStatus.ID 
		INNER JOIN customer ON bookings.customerID = customer.ID 
		WHERE bookings.partnerID = #internalPartnerID#
		ORDER BY bookings.created DESC 
		</cfquery>


			<cfset dataArray = arrayNew(1) />


				<cfloop query="bookings">
					
		
					<cfset dataArray[bookings.currentRow]['bookingID'] = bookings.bookingID />
					<cfset dataArray[bookings.currentRow]['courseID'] = bookings.listingID />
					<cfset dataArray[bookings.currentRow]['firstname'] = bookings.firstname />
					<cfset dataArray[bookings.currentRow]['surname'] = bookings.surname />
					<cfset dataArray[bookings.currentRow]['gender'] = bookings.gender />
					<cfset dataArray[bookings.currentRow]['age'] = dateDiff('yyyy',bookings.dob,now()) />


					<cfset dataArray[bookings.currentRow]['listingName'] = bookings.listingName />
					<cfset dataArray[bookings.currentRow]['totalPaid'] = bookings.totalPaid />
					<cfset dataArray[bookings.currentRow]['status']['ID'] = bookings.status />
					<cfset dataArray[bookings.currentRow]['status']['description'] = bookings.statusName />
					<cfset dataArray[bookings.currentRow]['created'] = dateFormat(bookings.created, "yyyy-mm-dd") & 'T' & timeFormat(bookings.created,"HH:mm:ss") & 'Z' />

				</cfloop>

				<cfset result['data'] = dataArray />

			<cfset objTools.runtime('get', '/partner/{partnerID}/bookings', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="customerID" type="string" required="false" default="" />
		<cfargument name="status" type="string" required="false" default="0" />
		<cfargument name="customer" type="string" required="false" default="" />
		<cfargument name="listingName" type="string" required="false" default="" />
		<cfargument name="theMonth" type="string" required="false" default="" />
		<cfargument name="theYear" type="string" required="false" default="" />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

        <cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

        <cfif arguments.customerID neq ''>
	        <cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
        </cfif>


		<cfquery name="bookings" datasource="startfly">
		SELECT 
		listing.sID AS listingID,
		listing.name as listingName,
		listing.howOften,
		listing.location,
		bookings.ID as internalBookingID,
		bookings.sID AS bookingID,
		bookings.customerID,
		bookings.created,
		bookings.totalPaid,
		bookings.gross,
		bookings.net,
		bookings.vat,
		bookings.status,
		bookingStatus.name as statusName, 
		(SELECT COUNT(*) FROM bookingDetail WHERE bookingID = bookings.ID)  AS totalSessions,
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
		locations.postcode as locationPostcode
		FROM bookings 
		INNER JOIN listing ON bookings.listingID = listing.ID 
		INNER JOIN bookingStatus on bookings.status = bookingStatus.ID 
		INNER JOIN customer ON bookings.customerID = customer.ID 
		LEFT JOIN locations ON listing.location = locations.ID
		WHERE bookings.partnerID = #internalPartnerID# 
        <cfif arguments.customerID neq ''>
        AND bookings.customerID = #internalCustomerID#
        </cfif>
        <cfif arguments.status neq 0 AND arguments.status neq ''>
	        AND bookings.status = #arguments.status#
        </cfif>
        <cfif arguments.customer neq ''>
        AND CONCAT(customer.firstname,' ',customer.surname) LIKE '%#arguments.customer#%'
        </cfif>
        <cfif arguments.listingName neq ''>
        AND listing.name LIKE '%#arguments.listingName#%'
        </cfif>
        <cfif arguments.theMonth neq ''>
        AND MONTH(bookings.created) = #arguments.theMonth#
        </cfif>
        <cfif arguments.theYear neq ''>
        AND YEAR(bookings.created) = #arguments.theYear#
        </cfif>
		ORDER BY bookings.created DESC 
		</cfquery>


			<cfset dataArray = arrayNew(1) />

				<cfloop query="bookings">

					<cfset expirationLimit = dateAdd('h',48,bookings.created) />
					<cfset confirmationExpires = dateDiff('h',now(),expirationLimit) />

					<cfif confirmationExpires lt 0>
						<cfset dataArray[bookings.currentRow]['confirmationExpires'] = 0 />
					<cfelse>
						<cfset dataArray[bookings.currentRow]['confirmationExpires'] = confirmationExpires />
					</cfif>

		
					<cfset dataArray[bookings.currentRow]['bookingID'] = bookings.bookingID />
					<cfset dataArray[bookings.currentRow]['listingID'] = bookings.listingID />
					<cfset dataArray[bookings.currentRow]['listingName'] = bookings.listingName />
					<cfset dataArray[bookings.currentRow]['totalPaid'] = bookings.totalPaid />
					<cfset dataArray[bookings.currentRow]['totalSessions'] = bookings.totalSessions />
					<cfset dataArray[bookings.currentRow]['created'] = dateFormat(bookings.created, "yyyy-mm-dd") & 'T' & timeFormat(bookings.created,"HH:mm:ss") & 'Z' />

					<cfset dataArray[bookings.currentRow]['customer']['firstname'] = bookings.firstname />
					<cfset dataArray[bookings.currentRow]['customer']['surname'] = bookings.surname />
					<cfset dataArray[bookings.currentRow]['customer']['gender'] = bookings.gender />
					<cfset dataArray[bookings.currentRow]['customer']['age'] = dateDiff('yyyy',bookings.dob,now()) />

					<cfset dataArray[bookings.currentRow]['status']['ID'] = bookings.status />
					<cfset dataArray[bookings.currentRow]['status']['description'] = bookings.statusName />

					<cfset dataArray[bookings.currentRow]['location']['name'] = bookings.locationName />
					<cfset dataArray[bookings.currentRow]['location']['town'] = bookings.locationTown />
					<cfset dataArray[bookings.currentRow]['location']['postcode'] = bookings.locationPostcode />


					<cfquery name="bookingDetails" datasource="startfly">
					SELECT 
					bookingDetail.sID as bookingDetailSID,
					sd.date as startDate,
					st.theHour as startHour,
					st.theMinute as startMinute,  
					ed.date as endDate,
					et.theHour as endHour,
					et.theMinute as endMinute,
					(SELECT COUNT(*) FROM bookingDetailAttendees WHERE bookingDetailID = bookingDetail.ID) as attending 
					FROM bookingDetail 
					INNER JOIN dimDate sd on bookingDetail.startDateID = sd.dateID
					INNER JOIN dimTime st on bookingDetail.startTimeID = st.timeID
					INNER JOIN dimDate ed on bookingDetail.endDateID = ed.dateID
					INNER JOIN dimTime et on bookingDetail.endTimeID = et.timeID
					WHERE bookingDetail.bookingID = #bookings.internalBookingID# 
					ORDER BY bookingDetail.startDateID, bookingDetail.startTimeID
					</cfquery>

					<cfset bookingDetailArray = arrayNew(1) />
					<cfloop query="bookingDetails">
						<cfset bookingDetailArray[bookingDetails.currentRow]['ID'] = bookingDetails.bookingDetailSID />
						<cfset bookingDetailArray[bookingDetails.currentRow]['attending'] = bookingDetails.attending />
						<cfset bookingDetailArray[bookingDetails.currentRow]['startDate'] = dateFormat(bookingDetails.startDate,"yyyy-mm-dd") & 'T' & numberFormat(bookingDetails.startHour,"00") &':'& numberFormat(bookingDetails.startMinute,"00") &':00Z' />
						<cfset bookingDetailArray[bookingDetails.currentRow]['endDate'] = dateFormat(bookingDetails.endDate,"yyyy-mm-dd") & 'T' & numberFormat(bookingDetails.endHour,"00") &':'& numberFormat(bookingDetails.endMinute,"00") &':00Z' />
					</cfloop>
					<cfset dataArray[bookings.currentRow]['bookingDetail'] = bookingDetailArray />



				</cfloop>

				<cfset result['data'] = dataArray />

			<cfset objTools.runtime('post', '/partner/{partnerID}/bookings', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
