<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/customer/{customerID}/stats" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfset result['data']['overview']['totalBookings'] = 0 />
		<cfset result['data']['overview']['totalSpend'] = 0 />
		<cfset result['data']['overview']['averageRating'] = 0 />
		<cfset result['data']['overview']['lastBookingDays'] = '' />
		<cfset result['data']['overview']['cancellations'] = 0 />

		<!--- last booking days --->
		<cfquery name="lastBooking" datasource="startfly">
		SELECT 
		DATEDIFF(NOW(),created) AS days
		FROM bookings 
		WHERE customerID = #internalCustomerID# 
		AND partnerID = #internalPartnerID# 
		AND bookings.status IN (1,2,5)
		ORDER BY ID DESC 
		LIMIT 1
		</cfquery>

		<cfset result['data']['overview']['lastBookingDays'] = lastBooking.days />

		<!--- overall rating --->
		<cfquery name="ratings" datasource="startfly">
		SELECT 
		SUM(rating) as totalRating,
		COUNT(*) as ratings 
		FROM reviews 
		WHERE customerID = #internalCustomerID# 
		AND partnerID = #internalPartnerID# 
		GROUP BY customerID, partnerID
		</cfquery>

		<cfif ratings.recordCount is 1>
			<cfset result['data']['overview']['averageRating'] = numberFormat((ratings.totalRating / ratings.ratings),'._') />
		</cfif>

		<!--- all bookings --->
		<cfquery name="bookings" datasource="startfly">
		SELECT 
		SUM(bookings.net) AS totalNet,
		SUM(bookings.commission) AS totalCommission,
		COUNT(*) AS totalBookings,
		(
			SELECT DATEDIFF(NOW(),created) 
			FROM bookings 
			WHERE customerID = #internalCustomerID# 
			AND partnerID = #internalPartnerID# 
			AND listingID = bookings.listingID
			ORDER BY ID 
			DESC LIMIT 1
		) as days,
		bookings.listingID AS listingInternalID,
		listing.sID AS listingID,
		listing.name 
		FROM bookings 
		INNER JOIN listing ON bookings.listingID = listing.ID 
		WHERE bookings.partnerID = #internalPartnerID# 
		AND bookings.customerID = #internalCustomerID# 
		AND bookings.status IN (1,2,5)
		GROUP BY listingID
		ORDER BY listing.name 
		</cfquery>

		<cfset result['data']['overview']['totalBookings'] = arraySum(listToArray(valueList(bookings.totalBookings))) />
		<cfset result['data']['overview']['totalSpend'] = arraySum(listToArray(valueList(bookings.totalNet))) - arraySum(listToArray(valueList(bookings.totalCommission))) />

		<cfloop query="bookings">
			<cfset result['data']['listings'][bookings.listingID]['name'] = bookings.name />
			<cfset result['data']['listings'][bookings.listingID]['lastBookingDays'] = bookings.days />
			<cfset result['data']['listings'][bookings.listingID]['totalBookings'] = bookings.totalBookings />
			<cfset result['data']['listings'][bookings.listingID]['totalSpend'] = bookings.totalNet - bookings.totalCommission />
			<cfset result['data']['listings'][bookings.listingID]['averageRating'] = 0 />
			<cfset result['data']['listings'][bookings.listingID]['cancellations'] = 0 />

			<!--- listing rating --->
			<cfquery name="ratings" datasource="startfly">
			SELECT 
			SUM(rating) as totalRating,
			COUNT(*) as ratings 
			FROM reviews 
			WHERE customerID = #internalCustomerID# 
			AND partnerID = #internalPartnerID# 
			AND listingID = #bookings.listingInternalID#
			GROUP BY customerID, partnerID
			</cfquery>

			<cfif ratings.recordCount is 1>
				<cfset result['data']['listings'][bookings.listingID]['averageRating'] = numberFormat((ratings.totalRating / ratings.ratings),'._') />
			</cfif>

		</cfloop>


		<cfset objTools.runtime('get', '/partner/{partnerID}/customer/{customerID}/stats', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
