<cfcomponent extends="taffy.core.resource" taffy:uri="/reviews/listing/{listingID}" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">
		<cfargument name="listingID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />

		<cfquery name="reviews" datasource="startfly">
		SELECT 
		reviews.sID,
		reviews.rating,
		reviews.comment,
		reviews.created,
		customer.avatar,
		CONCAT(customer.firstname,' ',customer.surname) AS name 
		FROM reviews 
		INNER JOIN customer ON reviews.customerID = customer.ID 
		WHERE reviews.listingID = #internalListingID# 
		AND reviews.status = 1
		</cfquery>

		<cfset dataArray = arrayNew(1) />

		<cfloop query="reviews">
			<cfset dataArray[reviews.currentRow]['rating'] = reviews.rating />
			<cfset dataArray[reviews.currentRow]['comment'] = reviews.comment />
			<cfif reviews.avatar is ''>
				<cfset dataArray[reviews.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/profile-avatar.png' />
			<cfelse>
				<cfset dataArray[reviews.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/customer/' & reviews.avatar />
			</cfif>
			<cfset dataArray[reviews.currentRow]['name'] = reviews.name />
			<cfset dataArray[reviews.currentRow]['created'] = objDates.toJSON(reviews.created) />
		</cfloop>

		<cfset result['data'] = dataArray />

		<cfset objTools.runtime('get', '/reviews/listing/{listingID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
