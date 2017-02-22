<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/reviews/filter" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="customerID" type="string" required="false" default="" />
		<cfargument name="reviewType" type="string" required="true" default="" />
		<cfargument name="unread" type="numeric" required="false" default="0" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
	
		<cfif arguments.customerID neq ''>
			<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		</cfif>
	
		<cfquery name="reviews" datasource="startfly">
		SELECT 
		reviews.sID,
		reviews.type,
		reviews.rating,
		reviews.comment,
		reviews.created,
		reviews.tagged,
		reviews.reported,
		customer.avatar,
		CONCAT(customer.firstname,' ',customer.surname) AS name,
		listing.name AS listingName,
		listing.sID AS listingSID
		FROM reviews 
		INNER JOIN customer ON reviews.customerID = customer.ID 
		LEFT JOIN listing ON reviews.listingID = listing.ID 
		WHERE reviews.partnerID = #internalPartnerID# 
		<cfif arguments.customerID neq ''>
		AND customerID = #internalCustomerID#
		</cfif>
		<cfif arguments.unRead is 1>
			AND reviews.isRead = 0
		</cfif>
		<cfswitch expression="#arguments.reviewType#">
			<cfcase value="listing">
				AND reviews.type = 'listing'
			</cfcase>
			<cfcase value="partner">
				AND reviews.type = 'partner'
			</cfcase>
		</cfswitch>
		AND reviews.status = 1 
		ORDER BY reviews.created DESC
		</cfquery>

		<cfset dataArray = arrayNew(1) />

		<cfloop query="reviews">
			<cfset dataArray[reviews.currentRow]['reviewID'] = reviews.sID />
			<cfset dataArray[reviews.currentRow]['type'] = reviews.type />
			<cfset dataArray[reviews.currentRow]['rating'] = reviews.rating />
			<cfset dataArray[reviews.currentRow]['comment'] = reviews.comment />
			<cfset dataArray[reviews.currentRow]['tagged'] = reviews.tagged />
			<cfset dataArray[reviews.currentRow]['reported'] = reviews.reported />
			<cfset dataArray[reviews.currentRow]['listingName'] = reviews.listingName />
			<cfset dataArray[reviews.currentRow]['listingSID'] = reviews.listingSID />
			<cfif reviews.avatar is ''>
				<cfset dataArray[reviews.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/profile-avatar.png' />
			<cfelse>
				<cfset dataArray[reviews.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/customer/' & reviews.avatar />
			</cfif>
			<cfset dataArray[reviews.currentRow]['name'] = reviews.name />
			<cfset dataArray[reviews.currentRow]['created'] = objDates.toJSON(reviews.created) />
		</cfloop>

		<cfset result['data'] = dataArray />

		<cfset objTools.runtime('get', '/partner/{partnerID}/reviews/filter', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
