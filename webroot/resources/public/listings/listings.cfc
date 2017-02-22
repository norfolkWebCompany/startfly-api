<cfcomponent extends="taffy.core.resource" taffy:uri="/public/listings" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="type" type="numeric" required="false" default="0" />

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

		<cfquery name="totalRecords" datasource="startfly">
		SELECT COUNT(*) AS totalRecs
		FROM listing 
		INNER JOIN listingCategory ON listing.ID = listingCategory.listingID 
		INNER JOIN courseCategory ON listingCategory.categoryID = courseCategory.ID 
		INNER JOIN partner ON listing.partnerID = partner.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN listingType ON listing.type = listingType.ID
		LEFT JOIN countries ON partner.country = countries.ID
		WHERE listing.status = 1 
		AND listing.deleted = 0
        AND (
        	listing.ID IN (#valueList(occurrences.listingID)#) 
        	OR 
        	listing.workingHours > 0
        	)
		AND locations.latitude <= #arguments.bounds.n#
		AND locations.latitude >= #arguments.bounds.s#
		AND locations.longitude >= #arguments.bounds.w#
		AND locations.longitude <= #arguments.bounds.e#
		<cfif arguments.type neq 0>
			AND listing.type = #arguments.type#
		</cfif>
		<cfif arguments.category neq ''>
			AND courseCategory.familyID = (SELECT familyID FROM courseCategory WHERE courseCategory.URL = '#arguments.category#')
		</cfif>
        <cfif isDefined("arguments.name") and arguments.name neq ''>
        AND CONCAT(listing.name,listing.previewText,listing.details) LIKE '%#arguments.name#%' 
        </cfif>
		</cfquery>

		<cfset result['pagination']['totalRecords'] = totalRecords.totalRecs />
		<cfset result['pagination']['pages'] = ceiling(totalRecords.totalRecs / arguments.pagination.limit) />


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
		countries.name AS countryName,
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
		LEFT JOIN countries ON partner.country = countries.ID
		WHERE listing.status = 1 
		AND listing.deleted = 0
        AND (
        	listing.ID IN (#valueList(occurrences.listingID)#) 
        	OR 
        	listing.workingHours > 0
        	)
		AND locations.latitude <= #arguments.bounds.n#
		AND locations.latitude >= #arguments.bounds.s#
		AND locations.longitude >= #arguments.bounds.w#
		AND locations.longitude <= #arguments.bounds.e#
		<cfif arguments.type neq 0>
			AND listing.type = #arguments.type#
		</cfif>
		<cfif arguments.category neq ''>
			AND courseCategory.familyID = (SELECT familyID FROM courseCategory WHERE courseCategory.URL = '#arguments.category#')
		</cfif>
        <cfif isDefined("arguments.name") and arguments.name neq ''>
        AND CONCAT(listing.name,listing.previewText,listing.details) LIKE '%#arguments.name#%' 
        </cfif>
		ORDER BY #arguments.orderBy.sortField# 
		<cfif arguments.orderBy.doReverse> 
		DESC
		</cfif>
		LIMIT #((arguments.pagination.currentPage * arguments.pagination.limit)-arguments.pagination.limit)#, #arguments.pagination.limit#
		</cfquery>


		<cfset dataArray = arrayNew(1) />
		<cfset mapArray = arrayNew(1) />

		<cfquery datasource="startfly" name="maxCost">
		SELECT Cost 
		FROM listing 
		ORDER BY cost DESC 
		LIMIT 1
		</cfquery>

		<cfset result['maxCost'] = maxCost.cost />

		<cfloop query="listings">
			
			<cfset dataArray[listings.currentRow]['listingID'] = listings.listingID />
			<cfset dataArray[listings.currentRow]['name'] = listings.name />
			<cfset dataArray[listings.currentRow]['url'] = listings.url />
			<cfset dataArray[listings.currentRow]['type'] = listings.type />
			<cfset dataArray[listings.currentRow]['typeName'] = listings.typeName />
			<cfset dataArray[listings.currentRow]['cost'] = listings.cost />
			<cfset dataArray[listings.currentRow]['capacity'] = listings.capacity />
			<cfset dataArray[listings.currentRow]['featured'] = listings.featured />
			<cfset dataArray[listings.currentRow]['imageURL'] = listings.imageURL />
			<cfset dataArray[listings.currentRow]['previewText'] = listings.previewText />
			<cfset dataArray[listings.currentRow]['created'] = objDates.fromEpoch(listings.created,'JSON') />

			<cfset dataArray[listings.currentRow]['location']['locationID'] = listings.location />
			<cfset dataArray[listings.currentRow]['location']['name'] = listings.locationName />
			<cfset dataArray[listings.currentRow]['location']['address1'] = listings.add1 />
			<cfset dataArray[listings.currentRow]['location']['address2'] = listings.add2 />
			<cfset dataArray[listings.currentRow]['location']['address3'] = listings.add3 />
			<cfset dataArray[listings.currentRow]['location']['town'] = listings.town />
			<cfset dataArray[listings.currentRow]['location']['county'] = listings.county />
			<cfset dataArray[listings.currentRow]['location']['country'] = listings.country />
			<cfset dataArray[listings.currentRow]['location']['countryName'] = listings.countryName />
			<cfset dataArray[listings.currentRow]['location']['postcode'] = listings.postcode />
			<cfset dataArray[listings.currentRow]['location']['hideAddress'] = listings.hideAddress />
			<cfset dataArray[listings.currentRow]['location']['longitude'] = listings.longitude />
			<cfset dataArray[listings.currentRow]['location']['latitude'] = listings.latitude />

			<cfset dataArray[listings.currentRow]['rating']['average'] = ceiling(listings.ratingAvg) />

			<cfif listings.longitude neq '' and listings.latitude neq ''>
				<cfset mapArrayLen = arrayLen(mapArray)+1 />
				<cfset mapArray[mapArrayLen]['locationID'] = listings.locationSID />
				<cfset mapArray[mapArrayLen]['longitude'] = listings.longitude />
				<cfset mapArray[mapArrayLen]['latitude'] = listings.latitude />
				<cfset mapArray[mapArrayLen]['markerPosition'] = listings.latitude & ',' & listings.longitude />
			</cfif>


			<cfset dataArray[listings.currentRow]['categories'] = arrayNew(1) />

			<cfquery name="categories" datasource="startfly">
			SELECT 
			courseCategory.name,
			courseCategory.URL,
			courseCategory.secureID 
			FROM listingCategory 
			INNER JOIN courseCategory ON listingCategory.categoryID = courseCategory.ID 
			WHERE listingCategory.listingID = '#listings.listingID#' 
			</cfquery>


			<cfloop query="categories">
				<cfset  dataArray[listings.currentRow]['categories'][categories.currentRow]['categoryID'] = categories.secureID />
				<cfset  dataArray[listings.currentRow]['categories'][categories.currentRow]['pageURL'] = categories.URL />
				<cfset  dataArray[listings.currentRow]['categories'][categories.currentRow]['categoryName'] = categories.name />
			</cfloop>

			<cfif listings.useBusinessName is 0>
				<cfset dataArray[listings.currentRow]['partner']['name'] = listings.firstname & ' ' & listings.surname />
				<cfset dataArray[listings.currentRow]['partner']['firstname'] = listings.firstname />
			<cfelse>
				<cfset dataArray[listings.currentRow]['partner']['name'] = listings.company />
				<cfset dataArray[listings.currentRow]['partner']['firstname'] = listings.company />
			</cfif>


			<cfset dataArray[listings.currentRow]['partner']['partnerID'] = listings.partnerID />
			<cfset dataArray[listings.currentRow]['partner']['nickname'] = listings.nickname />
			<cfset dataArray[listings.currentRow]['partner']['landline'] = listings.landline />
			<cfset dataArray[listings.currentRow]['partner']['mobile'] = listings.mobile />
			<cfset dataArray[listings.currentRow]['partner']['email'] = listings.email />
			<cfset dataArray[listings.currentRow]['partner']['gender'] = listings.gender />
			<cfset dataArray[listings.currentRow]['partner']['avatar'] = listings.avatar />


		</cfloop>

		<cfset result['data']['listings'] = dataArray />
		<cfset result['data']['mapData'] = mapArray />

		<cfset result['arguments'] = arguments />

		<cfset objTools.runtime('post', '/public/listings', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
