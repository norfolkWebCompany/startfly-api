<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/memberships" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset sTime = getTickCount() />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="memberships" datasource="startfly">
		SELECT 
		memberships.*,
		membershipBooking.dateIDCreated,
		membershipBooking.startDate as membershipStarts,
		membershipBooking.gross as bookingGross,
		partner.nickname
		FROM membershipBooking 
		INNER JOIN memberships ON membershipBooking.membershipID = memberships.ID 
		INNER JOIN partner ON membershipBooking.partnerID = partner.ID 
		WHERE memberships.status = 1 
		AND membershipBooking.customerID = #internalCustomerID# 
		</cfquery>


		<cfset data = arrayNew(1) />

		<cfloop query="memberships">
			<cfset data[memberships.currentRow]['membershipID'] = memberships.sID />
			<cfset data[memberships.currentRow]['name'] = memberships.name />
			<cfset data[memberships.currentRow]['value'] = memberships.bookingGross />
			<cfset data[memberships.currentRow]['partner']['name'] = memberships.nickname />
			<cfset data[memberships.currentRow]['startDate'] = objDates.getDim(memberships.membershipStarts,1,'JSON') />
			<cfset data[memberships.currentRow]['created'] = objDates.getDim(memberships.dateIDCreated,1,'JSON') />

			<cfquery name="listings" datasource="startfly">
			SELECT 
			listingMemberships.*,
			listing.sID AS listingSID 
			FROM listingMemberships 
			INNER JOIN listing ON listingMemberships.listingID = listing.ID  
			WHERE membershipID = #memberships.ID# 
			AND listing.deleted = 0
			</cfquery>

			<cfset listingArray = arrayNew(1) />
			<cfloop query="listings">
				<cfset listingArray[listings.currentRow]['ID'] = listings.listingSID />
				<cfset listingArray[listings.currentRow]['freeEntry'] = listings.freeEntry />
				<cfset listingArray[listings.currentRow]['freeEntryQty'] = listings.freeEntryQty />
				<cfset listingArray[listings.currentRow]['freeEntryPeriod'] = listings.freeEntryPeriod />
				<cfset listingArray[listings.currentRow]['discountedEntry'] = listings.discountedEntry />
				<cfset listingArray[listings.currentRow]['discountedEntryCost'] = listings.discountedEntryCost />
			</cfloop>
			<cfset data[memberships.currentRow]['listings'] = listingArray />
		</cfloop>

		<cfset result['data'] = data />	

		<cfset objTools.runtime('get', '/public/membership/{membershipID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
