<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/bookings/occurrences" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="customerID" type="string" required="true" />
		<cfargument name="partnerID" type="string" required="false" default="" />
		<cfargument name="familyMember" type="string" required="false" default="" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
        <cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalFamilyMemberID = objTools.internalID('customer',arguments.familyMember) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />
		<cfset result['arguments'] = arguments />

		<cfset dimNow = objDates.dimNow() />
		<cfset result['dimNow'] = dimNow />


<!--- 		<cfif isDefined("arguments.startDate") and arguments.startDate neq ''>
			<cfset sDate = objTools.cfDateFromJSON(arguments.startDate) />
			<cfset sDate = objTools.rootDay(sDate) />
			<cfset sDateSQL = 'AND listingOccurrence.starts >= ' & #sDate# />
		<cfelse>
			<cfset sDateSQL = '' />
		</cfif>

		<cfif isDefined("arguments.endDate") and arguments.endDate neq ''>
			<cfset eDate = objTools.cfDateFromJSON(arguments.endDate) />
			<cfset eDate = objTools.rootDay(eDate) />
			<cfset eDateSQL = 'AND listingOccurrence.ends <= ' & #eDate# />
		<cfelse>
			<cfset eDateSQL = '' />
		</cfif>
 --->


		<cfif isDefined("arguments.daysFromNow") and arguments.daysFromNow neq ''>
			<cfset endDateID = dimNow.dateID + arguments.daysFromNow />
			<cfset sDateSQL = 'AND bookingDetail.startDateID >= ' & #dimNow.dateID# />
			<cfset eDateSQL = 'AND bookingDetail.endDateID <= ' & #endDateID# />
		<cfelse>
			<cfset sDateSQL = '' />
			<cfset eDateSQL = '' />
		</cfif>

		<cfquery name="totalRecords" datasource="startfly">
		SELECT COUNT(*) AS totalRecs
		FROM bookingDetail 
		INNER JOIN listing ON bookingDetail.listingID = listing.ID 
		LEFT JOIN listingOccurrence ON bookingDetail.occurrenceID = listingOccurrence.ID
		LEFT JOIN partner ON listing.partnerID = partner.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		LEFT JOIN listingType ON listing.type = listingType.ID
		LEFT JOIN bookingStatus on bookingDetail.status = bookingStatus.ID 
		LEFT JOIN countries ON partner.country = countries.ID
		WHERE bookingDetail.customerID = #internalCustomerID# 
		#sDateSQL#
		#eDateSQL#
        <cfif isDefined("arguments.name") and arguments.name neq ''>
        AND listing.name LIKE '%#arguments.name#%' 
        </cfif>
        <cfif isDefined("arguments.partnerID") and arguments.partnerID neq ''>
        AND listing.partnerID = #internalPartnerID# 
        </cfif>
        <cfif isDefined("arguments.familyMember") and arguments.familyMember neq ''>
        AND bookingDetail.bookedFor = #internalFamilyMemberID# 
        </cfif>
        <cfif isDefined("arguments.bookingStatus") and arguments.bookingStatus neq ''>
        AND bookingDetail.status = #arguments.bookingStatus# 
        </cfif>
		</cfquery>

		<cfset result['pagination']['totalRecords'] = totalRecords.totalRecs />
		<cfset result['pagination']['pages'] = ceiling(totalRecords.totalRecs / arguments.pagination.limit) />

		<cfquery name="bookings" datasource="startfly" result="qResult">
		SELECT 
		listing.sID AS listingID,
		listing.name AS listingName,
		listing.location,
		listing.type,
		listingType.name as typeName,
		listingOccurrence.sID AS occurrenceID,
		listingOccurrence.starts,
		listingOccurrence.ends,
		locations.name AS locationName,
		locations.longitude,
		locations.latitude,
		locations.add1,
		locations.add2,
		locations.add3,
		locations.town,
		locations.county,
		locations.country,
		locations.postcode,
		locations.hideAddress,
		partner.sID AS partnerID,
		partner.firstName,
		partner.surname,
		partner.nickname,
		partner.company,
		partner.landline,
		partner.mobile,
		partner.email, 
		partner.gender,
		partner.avatar,
		partner.useBusinessName,
		bookingDetail.sID AS bookingID,
		bookingDetail.created,
		bookingDetail.status,
		bookingDetail.duration,
		bookingStatus.name as statusName,
		bookingDetail.startDateID,
		bookingDetail.startTimeID,
		bookingDetail.endDateID,
		bookingDetail.endTimeID
		FROM bookingDetail 
		INNER JOIN listing ON bookingDetail.listingID = listing.ID 
		LEFT JOIN listingOccurrence ON bookingDetail.occurrenceID = listingOccurrence.ID
		LEFT JOIN partner ON listing.partnerID = partner.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		LEFT JOIN listingType ON listing.type = listingType.ID
		LEFT JOIN bookingStatus on bookingDetail.status = bookingStatus.ID 
		WHERE bookingDetail.customerID = #internalCustomerID# 
		#sDateSQL#
		#eDateSQL#
        <cfif isDefined("arguments.name") and arguments.name neq ''>
        AND listing.name LIKE '%#arguments.name#%' 
        </cfif>
        <cfif isDefined("arguments.partnerID") and arguments.partnerID neq ''>
        AND listing.partnerID = #internalPartnerID# 
        </cfif>
        <cfif isDefined("arguments.familyMember") and arguments.familyMember neq ''>
        AND bookingDetail.bookedFor = #internalFamilyMemberID# 
        </cfif>
        <cfif isDefined("arguments.bookingStatus") and arguments.bookingStatus neq ''>
        AND bookingDetail.status = #arguments.bookingStatus# 
        </cfif>
		ORDER BY #arguments.orderBy.sortField# 
		<cfif arguments.orderBy.doReverse> 
		DESC
		</cfif>
		LIMIT #((arguments.pagination.currentPage * arguments.pagination.limit)-arguments.pagination.limit)#, #arguments.pagination.limit#
		</cfquery>


		<cfset result['query'] = qResult />


			<cfset dataArray = arrayNew(1) />

				<cfloop query="bookings">
					
		
					<cfset dataArray[bookings.currentRow]['bookingID'] = bookings.bookingID />
					<cfset dataArray[bookings.currentRow]['occurrenceID'] = bookings.occurrenceID />
					<cfset dataArray[bookings.currentRow]['listingID'] = bookings.listingID />
					<cfset dataArray[bookings.currentRow]['listingName'] = bookings.listingName />
					<cfset dataArray[bookings.currentRow]['type'] = bookings.type />
					<cfset dataArray[bookings.currentRow]['typeName'] = bookings.typeName />

					<cfset dataArray[bookings.currentRow]['startDate'] = objDates.getDim(bookings.startDateID,bookings.startTimeID,'JSON') /> />
					<cfset dataArray[bookings.currentRow]['endDate'] = objDates.getDim(bookings.endDateID,bookings.endTimeID,'JSON') /> />


					<cfset dataArray[bookings.currentRow]['location']['locationID'] = bookings.location />
					<cfset dataArray[bookings.currentRow]['location']['name'] = bookings.locationName />
					<cfset dataArray[bookings.currentRow]['location']['address1'] = bookings.add1 />
					<cfset dataArray[bookings.currentRow]['location']['address2'] = bookings.add2 />
					<cfset dataArray[bookings.currentRow]['location']['address3'] = bookings.add3 />
					<cfset dataArray[bookings.currentRow]['location']['town'] = bookings.town />
					<cfset dataArray[bookings.currentRow]['location']['county'] = bookings.county />
					<cfset dataArray[bookings.currentRow]['location']['postcode'] = bookings.postcode />
					<cfset dataArray[bookings.currentRow]['location']['hideAddress'] = bookings.hideAddress />
					<cfset dataArray[bookings.currentRow]['location']['longitude'] = bookings.longitude />
					<cfset dataArray[bookings.currentRow]['location']['latitude'] = bookings.latitude />

					<cfset dataArray[bookings.currentRow]['partner']['partnerID'] = bookings.partnerID />
					<cfset dataArray[bookings.currentRow]['partner']['gender'] = bookings.gender />
					<cfset dataArray[bookings.currentRow]['partner']['avatar'] = bookings.avatar />
					<cfset dataArray[bookings.currentRow]['partner']['nickname'] = bookings.nickname />

					<cfif bookings.useBusinessName is 0>
						<cfset dataArray[bookings.currentRow]['partner']['name'] = bookings.firstname & ' ' & bookings.surname />
						<cfset dataArray[bookings.currentRow]['partner']['firstname'] = bookings.firstname />
						<cfset dataArray[bookings.currentRow]['partner']['surname'] = '' />
					<cfelse>
						<cfset dataArray[bookings.currentRow]['partner']['name'] = bookings.company />
						<cfset dataArray[bookings.currentRow]['partner']['firstname'] = bookings.company />
						<cfset dataArray[bookings.currentRow]['partner']['surname'] = bookings.surname />
					</cfif>



					<cfset dataArray[bookings.currentRow]['status']['ID'] = bookings.status />
					<cfset dataArray[bookings.currentRow]['status']['description'] = bookings.statusName />
					<cfset dataArray[bookings.currentRow]['created'] = objDates.fromEpoch(bookings.created,'JSON') /> />

<!--- 					<cfquery name="reviews" datasource="startfly">
					listingRatings.ID,
					listingRatings.rating,
					listingRatings.review 
					FROM listingRatings 
					WHERE listingID = '#bookings.listingID#' 
					AND customerID = #arguments.customerID#
					</cfquery>

					<cfset reviewArray = arrayNew(1) />

					<cfloop query="reviews">
						<cfset reviewArray[reviews.currentRow]['ID'] = reviews.ID />
						<cfset reviewArray[reviews.currentRow]['rating'] = reviews.rating />
						<cfset reviewArray[reviews.currentRow]['review'] = reviews.review />
					</cfloop>

					<cfset dataArray[bookings.currentRow]['reviews'] = reviewArray />
 --->
				</cfloop>

				<cfset result['data'] = dataArray />


			<cfset objTools.runtime('post', '/customer/{customerID}/bookings/occurrences', (getTickCount() - sTime) ) />


		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
