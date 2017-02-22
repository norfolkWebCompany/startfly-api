<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/reviews/listings" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfquery name="reviews" datasource="startfly">
		SELECT 
		reviews.*,
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
		INNER JOIN listing ON reviews.listingID = listing.ID 
		WHERE reviews.partnerID = #internalPartnerID# 
		AND reviews.type = 'listing'
		AND reviews.status = 1 
		AND reviews.rating >= #arguments.rating#
		<cfif arguments.tagged neq 999>
			AND reviews.tagged =  #arguments.tagged# 
		</cfif> 
        <cfif arguments.customer neq ''>
        AND CONCAT(customer.firstname,' ',customer.surname) LIKE '%#arguments.customer#%'
        </cfif>
        <cfif arguments.listingName neq ''>
        AND listing.name LIKE '%#arguments.listingName#%'
        </cfif>
		</cfquery>

		<cfset dataArray = arrayNew(1) />

		<cfloop query="reviews">
			<cfset dataArray[reviews.currentRow]['reviewID'] = reviews.sID />
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

		<cfset objTools.runtime('post', '/partner/{partnerID}/reviews/listings', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
