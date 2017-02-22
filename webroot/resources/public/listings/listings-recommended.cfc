<cfcomponent extends="taffy.core.resource" taffy:uri="/public/listings/recommended" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="type" type="numeric" required="false" default="0" />
		<cfargument name="listingID" type="string" required="false" default="" />
		<cfargument name="category" type="string" required="false" default="" />
		<cfargument name="distance" type="numeric" required="false" default="" />

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />


		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset sDate = objDates.setDim({date=now()}) />


		<cfquery name="occurrences" datasource="startfly" result="oc">
		SELECT 
		listingOccurrence.listingID 
		FROM listingOccurrence 
		WHERE startDateID > #sDate.dateID# 
		AND archive = 0
		GROUP BY listingID
		</cfquery>

		<cfset result['qOccurrences'] = oc />

		<cfquery name="listing" datasource="startfly">
		SELECT 
		listing.ID,
		locations.longitude,
		locations.latitude,
		courseCategory.ID,
		courseCategory.parentID,
		courseCategory.familyID,
		courseCategory.level
		FROM listing 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN listingCategory ON listing.ID = listingCategory.listingID 
		INNER JOIN courseCategory ON listingCategory.categoryID = courseCategory.ID 
		WHERE listing.sID = '#arguments.listingID#' 
		</cfquery>

		<cfquery name="listings" datasource="startfly">
		SELECT 
		listing.sID AS listingID,
		listing.name,
		listing.url,
		listing.imageURL,
		listing.location,
		listing.cost,
		listing.capacity,
		listing.featured,
		listing.previewText,
		listing.paymentPlan,
		listing.created,
		listing.howOften,
		listing.type,
		locations.sID as locationSID,
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
		3963 * (ACOS((SIN(#listing.latitude#/57.2958) * SIN(locations.latitude/57.2958)) + (COS(#listing.latitude#/57.2958) * COS(locations.latitude/57.2958) * COS(locations.longitude/57.2958 - #listing.longitude#/57.2958)))) AS distance,
		listingType.name as typeName,
		partner.ID AS partnerID,
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
		(
			SELECT 
			IFNULL( ( SUM(reviews.rating) / COUNT(*) ),0) 
			FROM reviews 
			WHERE type = 'listing' 
			AND listingID = listing.ID 
		) AS ratingAvg,
		IFNULL(
			(
			SELECT startDateID 
			FROM listingOccurrence 
			WHERE listingID = listing.ID 
			ORDER BY startDateID 
			LIMIT 1

		),0) AS startDateID   
		FROM listing 
		INNER JOIN listingCategory ON listing.ID = listingCategory.listingID 
		INNER JOIN courseCategory ON listingCategory.categoryID = courseCategory.ID 
		INNER JOIN partner ON listing.partnerID = partner.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN listingType ON listing.type = listingType.ID
		WHERE listing.status = 1 
		AND listing.deleted = 0 
		AND listing.sID <> '#arguments.listingID#'
        AND (
        	listing.ID IN (#valueList(occurrences.listingID)#) 
        	OR 
        	listing.workingHours > 0
        	)
        AND 3963 * (ACOS((SIN(#listing.latitude#/57.2958) * SIN(locations.latitude/57.2958)) + (COS(#listing.latitude#/57.2958) * COS(locations.latitude/57.2958) * COS(locations.longitude/57.2958 - #listing.longitude#/57.2958)))) <= 50
		<cfif arguments.type neq 0>
			AND listing.type = #arguments.type#
		</cfif>
		AND courseCategory.parentID = #listing.parentID#

		ORDER BY distance 
		LIMIT 4
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfloop query="listings">
			
			<cfset dataArray[listings.currentRow]['listingID'] = listings.listingID />
			<cfset dataArray[listings.currentRow]['name'] = listings.name />
			<cfset dataArray[listings.currentRow]['url'] = listings.url />
			<cfset dataArray[listings.currentRow]['type'] = listings.type />
			<cfset dataArray[listings.currentRow]['typeName'] = listings.typeName />
			<cfset dataArray[listings.currentRow]['cost'] = listings.cost />
			<cfset dataArray[listings.currentRow]['imageURL'] = listings.imageURL />

			<cfset dataArray[listings.currentRow]['location']['name'] = listings.locationName />
			<cfset dataArray[listings.currentRow]['location']['address1'] = listings.add1 />
			<cfset dataArray[listings.currentRow]['location']['town'] = listings.town />
			<cfset dataArray[listings.currentRow]['location']['hideAddress'] = listings.hideAddress />

			<cfset dataArray[listings.currentRow]['rating']['average'] = ceiling(listings.ratingAvg) />

			<cfif listings.useBusinessName is 0>
				<cfset dataArray[listings.currentRow]['partner']['name'] = listings.firstname & ' ' & listings.surname />
				<cfset dataArray[listings.currentRow]['partner']['firstname'] = listings.firstname />
			<cfelse>
				<cfset dataArray[listings.currentRow]['partner']['name'] = listings.company />
				<cfset dataArray[listings.currentRow]['partner']['firstname'] = listings.company />
			</cfif>

			<cfset dataArray[listings.currentRow]['partner']['partnerID'] = listings.partnerID />
			<cfset dataArray[listings.currentRow]['partner']['nickname'] = listings.nickname />


		</cfloop>

		<cfset result['data']['listings'] = dataArray />

		<cfset result['data']['arguments'] = arguments />

		<cfset objTools.runtime('post', '/public/listings/recommended', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>
</cfcomponent>
