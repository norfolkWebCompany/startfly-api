<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/memberships/{listingID}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset sTime = getTickCount() />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="listings" datasource="startfly">
		SELECT 
		listingMemberships.*,
		listing.sID AS listingSID,
		memberships.name as membershipName,
		memberships.isGroup,
		memberships.groupMin,
		memberships.groupMax,
		membershipBooking.ID AS membershipBookingID
		FROM listingMemberships 
		INNER JOIN listing ON listingMemberships.listingID = listing.ID  
		INNER JOIN memberships ON listingMemberships.membershipID = memberships.ID
		INNER JOIN membershipBooking ON listingMemberships.membershipID = membershipBooking.membershipID
		WHERE listingMemberships.listingID = #internalListingID# 
		AND membershipBooking.customerID = #internalCustomerID# 
		ORDER BY listingMemberships.freeEntry DESC 
		LIMIT 1
		</cfquery>



		<cfset listingArray = arrayNew(1) />
		<cfloop query="listings">
			<cfset listingArray[listings.currentRow]['membershipBookingID'] = listings.membershipBookingID />
			<cfset listingArray[listings.currentRow]['membershipName'] = replace(listings.membershipName,"'","","ALL") />
			<cfset listingArray[listings.currentRow]['groupMembership'] = listings.isGroup />
			<cfset listingArray[listings.currentRow]['groupMin'] = listings.groupMin />
			<cfset listingArray[listings.currentRow]['groupMax'] = listings.groupMax />
			<cfif listings.freeEntry is 1>
				<cfset listingArray[listings.currentRow]['freeEntry'] = listings.freeEntry />
				<cfset listingArray[listings.currentRow]['freeEntryQty'] = listings.freeEntryQty />
				<cfset listingArray[listings.currentRow]['freeEntryPeriod'] = listings.freeEntryPeriod />
			</cfif>
			<cfif listings.discountedEntry is 1>
				<cfset listingArray[listings.currentRow]['discountedEntry'] = listings.discountedEntry />
				<cfset listingArray[listings.currentRow]['discountedEntryCost'] = listings.discountedEntryCost />
			</cfif>
		</cfloop>

		<cfset result['data'] = listingArray />	

		<cfset objTools.runtime('get', '/customer/{customerID}/memberships/{listingID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
