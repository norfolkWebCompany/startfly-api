<cfcomponent extends="taffy.core.resource" taffy:uri="/public/listings/distance" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="type" type="numeric" required="false" default="0" />
		<cfargument name="position" type="array" required="false"  />
		<cfargument name="distance" type="numeric" required="false" default="5" />
		<cfargument name="category" type="string" required="false" default="" />
		<cfargument name="categoryID" type="string" required="false" default="" />
		<cfargument name="customerID" type="string" required="false" default="">

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />


		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset sDate = objDates.setDim({date=now()}) />

		<cfset showTestContent = 0 />

		<cfquery name="customer" datasource="startfly">
		SELECT showTestContent 
		FROM customer 
		WHERE sID = '#arguments.customerID#' 
		LIMIT 1
		</cfquery>

		<cfif customer.recordCount is 1>
			<cfset showTestContent = customer.showTestContent />
		</cfif>


<!--- 		<cfquery name="occurrences" datasource="startfly" result="oc">
		SELECT 
		DISTINCT listingOccurrence.listingID 
		FROM listingOccurrence 
		WHERE startDateID > #sDate.dateID# 
		AND archive = 0
		GROUP BY listingID
		</cfquery>
 --->


		<cfquery name="categories" datasource="startfly" >
		SELECT 
		DISTINCT courseCategory.ID,
		courseCategory.parentID,
		courseCategory.name
		FROM listing 
		INNER JOIN partner ON listing.partnerID = partner.ID 
		INNER JOIN courseCategory ON listing.categoryID = courseCategory.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN listingType ON listing.type = listingType.ID 
		LEFT JOIN listingOccurrence ON listing.ID = listingOccurrence.listingID
		WHERE listing.status = 1 
		AND listing.deleted = 0
		<cfif showTestContent is 0>
		AND partner.isTest = 0
		</cfif>
		AND 
		(
			listingOccurrence.startDateID > #sDate.dateID# 
			AND listingOccurrence.archive = 0 
			OR listing.workingHours > 0
		)
        <cfif arguments.address neq ''>
        AND 3963 * (ACOS((SIN(#arguments.position[1]#/57.2958) * SIN(locations.latitude/57.2958)) + (COS(#arguments.position[1]#/57.2958) * COS(locations.latitude/57.2958) * COS(locations.longitude/57.2958 - #arguments.position[2]#/57.2958)))) <= #arguments.distance#
        </cfif>
		<cfif arguments.type neq 0>
			AND listing.type = #arguments.type#
		</cfif>
        <cfif isDefined("arguments.name") and arguments.name neq ''>
        AND CONCAT(listing.name,listing.previewText,listing.details) LIKE '%#arguments.name#%' 
        </cfif>
		ORDER BY courseCategory.name
		</cfquery>


		<cfset categoriesArray = arrayNew(1) />


		<cfloop query="categories">
			<cfset categoriesArray[categories.currentRow]['ID'] = categories.ID />

			<cfif categories.parentID is 0>
			<cfset categoriesArray[categories.currentRow]['name'] = categories.name />
			<cfelse>
				<cfquery name="parent" datasource="startfly">
				SELECT courseCategory.name 
				From courseCategory 
				WHERE ID = #categories.parentID# 
				LIMIT 1
				</cfquery>
				
				<cfset categoriesArray[categories.currentRow]['name'] = parent.name & ' / ' & categories.name />
			</cfif>


		</cfloop>

		<cfset result['data']['categories'] = categoriesArray />











		<cfquery name="totalRecords" datasource="startfly">
		SELECT COUNT(DISTINCT listing.ID) AS totalRecs
		FROM listing 
		INNER JOIN courseCategory ON listing.categoryID = courseCategory.ID 
		INNER JOIN partner ON listing.partnerID = partner.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN listingType ON listing.type = listingType.ID 
		LEFT JOIN listingOccurrence ON listing.ID = listingOccurrence.listingID
		WHERE listing.status = 1 
		AND listing.deleted = 0
		<cfif showTestContent is 0>
		AND partner.isTest = 0
		</cfif>
		AND 
		(
			listingOccurrence.startDateID > #sDate.dateID# 
			AND listingOccurrence.archive = 0 
			OR listing.workingHours > 0
		)
        <cfif arguments.address neq ''>
        AND 3963 * (ACOS((SIN(#arguments.position[1]#/57.2958) * SIN(locations.latitude/57.2958)) + (COS(#arguments.position[1]#/57.2958) * COS(locations.latitude/57.2958) * COS(locations.longitude/57.2958 - #arguments.position[2]#/57.2958)))) <= #arguments.distance#
        </cfif>
		<cfif arguments.type neq 0>
			AND listing.type = #arguments.type#
		</cfif>
		<cfif arguments.categoryID neq ''>
			AND courseCategory.ID = #arguments.categoryID#
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


		<cfquery name="listings" datasource="startfly" >
		SELECT 
		DISTINCT listing.sID AS listingID,
		listing.ID AS internalListingID,
		listing.name,
		listing.url,
		listing.imageURL,
		listing.location,
		listing.cost,
		listing.locationType,
		listing.maxTravelMiles,
		listing.occurrenceType,
		locations.name AS locationName,
		locations.longitude,
		locations.latitude,
		locations.town,
		locations.hideAddress,
		3963 * (ACOS((SIN(#arguments.position[1]#/57.2958) * SIN(locations.latitude/57.2958)) + (COS(#arguments.position[1]#/57.2958) * COS(locations.latitude/57.2958) * COS(locations.longitude/57.2958 - #arguments.position[2]#/57.2958)))) AS distance,
		listingType.name as typeName,
		partner.firstName,
		partner.surname,
		partner.nickname,
		partner.company,
		partner.useBusinessName,
		(
			SELECT 
			IFNULL( ( SUM(reviews.rating) / COUNT(*) ),0) 
			FROM reviews 
			WHERE type = 'listing' 
			AND listingID = listing.ID 
		) AS ratingAvg
		FROM listing 
		INNER JOIN courseCategory ON listing.categoryID = courseCategory.ID 
		INNER JOIN partner ON listing.partnerID = partner.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN listingType ON listing.type = listingType.ID
		LEFT JOIN listingOccurrence ON listing.ID = listingOccurrence.listingID
		WHERE listing.status = 1 
		AND listing.deleted = 0
		<cfif showTestContent is 0>
		AND partner.isTest = 0
		</cfif>
		AND 
		(
			listingOccurrence.startDateID > #sDate.dateID# 
			AND listingOccurrence.archive = 0 
			OR listing.workingHours > 0
		)
        <cfif arguments.address neq ''>
        AND 3963 * (ACOS((SIN(#arguments.position[1]#/57.2958) * SIN(locations.latitude/57.2958)) + (COS(#arguments.position[1]#/57.2958) * COS(locations.latitude/57.2958) * COS(locations.longitude/57.2958 - #arguments.position[2]#/57.2958)))) <= #arguments.distance#
        </cfif>
		<cfif arguments.type neq 0>
			AND listing.type = #arguments.type#
		</cfif>
		<cfif arguments.categoryID neq ''>
			AND courseCategory.ID = #arguments.categoryID#
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
			<cfset dataArray[listings.currentRow]['typeName'] = listings.typeName />
			<cfset dataArray[listings.currentRow]['cost'] = listings.cost />
			<cfset dataArray[listings.currentRow]['locationType'] = listings.locationType />
			<cfset dataArray[listings.currentRow]['maxTravelMiles'] = listings.maxTravelMiles />

			<cfset dataArray[listings.currentRow]['location']['name'] = listings.locationName />
			<cfset dataArray[listings.currentRow]['location']['town'] = listings.town />
			<cfset dataArray[listings.currentRow]['location']['hideAddress'] = listings.hideAddress />

			<cfset dataArray[listings.currentRow]['rating']['average'] = ceiling(listings.ratingAvg) />

			<cfswitch expression="#listings.occurrenceType#">
				<cfcase value="8">
					<cfset dataArray[listings.currentRow]['occurrenceDescription'] = 'Working Hours' />
				</cfcase>
				<cfdefaultcase>
					<cfset dataArray[listings.currentRow]['occurrenceDescription'] = 'Ongoing' />
				</cfdefaultcase>
			</cfswitch>

			<cfif listings.longitude neq '' and listings.latitude neq ''>
				<cfset mapArrayLen = arrayLen(mapArray)+1 />
				<cfset mapArray[mapArrayLen]['longitude'] = listings.longitude />
				<cfset mapArray[mapArrayLen]['latitude'] = listings.latitude />
				<cfset mapArray[mapArrayLen]['markerPosition'] = listings.latitude & ',' & listings.longitude />
			</cfif>

			<cfif listings.useBusinessName is 0>
				<cfset dataArray[listings.currentRow]['partner']['name'] = listings.firstname & ' ' & listings.surname />
				<cfset dataArray[listings.currentRow]['partner']['firstname'] = listings.firstname />
			<cfelse>
				<cfset dataArray[listings.currentRow]['partner']['name'] = listings.company />
				<cfset dataArray[listings.currentRow]['partner']['firstname'] = listings.company />
			</cfif>
			<cfset dataArray[listings.currentRow]['partner']['nickname'] = listings.nickname />


			<cfquery name="images" datasource="startfly">
			SELECT 
			images.imagePath,
			images.groupID 
			FROM listingImages 
			INNER JOIN images ON listingImages.imageID = images.ID  
			WHERE listingImages.listingID = #listings.internalListingID#
			AND images.type = 'listing' 
			AND images.size = 'cover'
			AND images.status = 1 
			AND images.archive = 0 
			ORDER BY listingImages.sortOrder 
			LIMIT 1
			</cfquery>

			<cfset dataArray[listings.currentRow]['images'] = arrayNew(1) />

			<cfloop query="images">

				<cfquery name="tileImage" datasource="startfly">
				SELECT imagePath 
				FROM images 
				WHERE groupID = #images.groupID# 
				AND size = 'tile'
				</cfquery>

				<cfset imgPath = 'https://beta.startfly.co.uk/images/library/' & tileImage.imagePath />
				<cfset arrayAppend(dataArray[listings.currentRow]['images'],imgPath) /> 	
			</cfloop>


			<cfif images.recordCount is 0>
					<cfset arrayAppend(dataArray[listings.currentRow]['images'],listings.imageURL) /> 	
			</cfif>


		</cfloop>

		<cfset result['data']['listings'] = dataArray />
		<cfset result['data']['mapData'] = mapArray />
		<cfset result['data']['arguments'] = arguments />


		<cfset objTools.runtime('post', '/public/listings/distance', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
