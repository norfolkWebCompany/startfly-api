<cfcomponent extends="taffy.core.resource" taffy:uri="/public/listings/{url}" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">
		<cfargument name="url" type="string" required="true" />

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="listings" datasource="startfly">
		SELECT 
		listing.ID AS listingID,
		listing.sID AS listingSID,
		listing.name,
		listing.url,
		listing.imageURL,
		listing.location,
		listing.cost,
		listing.capacity,
		listing.minAttendees,
		listing.ageMin,
		listing.ageMax,
		listing.membersOnly,
		listing.previewText,
		listing.details,
		listing.pricingModel,
		listing.paymentPlan,
		listing.paymentPlanPayments,
		listing.paymentPlanFrequency,
		listing.created,
		listing.type,
		listing.occurrenceType,
		listing.workingHours,
		listing.cancellationPolicy,
		listing.duration,
		listing.intervalBreak,
		listing.minBookingQty,
		listing.splitOccurrences,
		listing.terms,
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
		partner.SID AS partnerSID,
		partner.firstName,
		partner.surname,
		partner.nickname,
		partner.company,
		partner.previewText AS partnerPreview,
		partner.gender,
		partner.avatar,
		partner.created AS partnerCreated,
		partner.useBusinessName,
		partner.webURL,
		partner.fbURL,
		partner.twitterURL,
		partner.instagramURL,
		partner.youtubeURL,
		countries.name AS countryName,
		paymentFrequency.name AS paymentPlanFrequencyName,
		(
			SELECT 
			IFNULL( ( SUM(reviews.rating) / COUNT(*) ),0) 
			FROM reviews 
			WHERE type = 'listing' 
			AND listingID = listing.ID 
		) AS ratingAvg   
		FROM listing 
		INNER JOIN partner ON listing.partnerID = partner.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN listingType ON listing.type = listingType.ID 
		INNER JOIN paymentFrequency ON listing.paymentPlanFrequency = paymentFrequency.ID
		LEFT JOIN countries ON partner.country = countries.ID
		WHERE listing.url = '#arguments.url#'
		AND listing.status = 1 
		AND listing.deleted = 0 
		LIMIT 1
		</cfquery>


		<!--- calculate the spaces left (based on the listing type) --->
		<cfswitch expression="#listings.type#">
			<cfcase value="1">
				<cfquery name="attendeesToDate" datasource="startfly">
				SELECT qty 
				FROM bookingDetail 
				WHERE listingID = #listings.listingID# 
				AND bookingDetail.status = 2 
				LIMIT 1
				</cfquery>

				<cfif attendeesToDate.recordCount neq 0>
					<cfset result['data']['spaces'] = (listings.capacity - valueList(attendeesToDate.qty)) />
				<cfelse>
					<cfset result['data']['spaces'] = listings.capacity />
				</cfif>

			</cfcase>
			<cfdefaultcase>

				<cfquery name="attendeesToDate" datasource="startfly">
				SELECT IFNULL(SUM(qty),0) as qty 
				FROM bookingDetail 
				WHERE listingID = #listings.listingID# 
				AND bookingDetail.status = 2 
				LIMIT 1
				</cfquery>

				<cfif attendeesToDate.recordCount neq 0>
					<cfset result['data']['spaces'] = (listings.capacity - valueList(attendeesToDate.qty)) />
				<cfelse>
					<cfset result['data']['spaces'] = listings.capacity />
				</cfif>


<!--- 				<cfif listings.attendeesToDate neq ''>
					<cfset result['data']['spaces'] = (listings.capacity - listings.attendeesToDate) />

					<cfif result['data']['spaces'] lt 0>
						<cfset result['data']['spaces'] = 0 />
					</cfif>

				<cfelse>
					<cfset result['data']['spaces'] = listings.capacity />
				</cfif>
 --->			</cfdefaultcase>
		</cfswitch>





			<cfset result['data']['listingID'] = listings.listingSID />
			<cfset result['data']['lID'] = listings.listingID />
			<cfset result['data']['name'] = listings.name />
			<cfset result['data']['url'] = 'http://beta.startfly.co.uk/##/listings/details/' & listings.URL />
			<cfset result['data']['type'] = listings.type />
			<cfset result['data']['typeName'] = listings.typeName />
			<cfset result['data']['cost'] = listings.cost />
			<cfset result['data']['pricingModel']['ID'] = listings.pricingModel />
			<cfif listings.pricingModel is 1>
				<cfset result['data']['pricingModel']['description'] = 'per booking' />
			<cfelse>
				<cfset result['data']['pricingModel']['description'] = 'per attendee' />
			</cfif>
			<cfset result['data']['occurrenceType'] = listings.occurrenceType />
			<cfset result['data']['attendeesMin'] = listings.minAttendees />
			<cfset result['data']['attendeesMax'] = listings.capacity />
			<cfset result['data']['minBookingQty'] = listings.minBookingQty />
			<cfset result['data']['duration'] = listings.duration />
			<cfset result['data']['intervalBreak'] = listings.intervalBreak />
			<cfset result['data']['splitOccurrences'] = listings.splitOccurrences />



			<cfset result['data']['membersOnly'] = listings.membersOnly />

			<cfset result['data']['ageMin'] = 0 />
			<cfset result['data']['ageMax'] = 110 />
			<cfset result['data']['imageURL'] = listings.imageURL />

			<cfset result['data']['imageCoverURL'] = replace(listings.imageURL,'tile-','cover-') />

			<cfset result['data']['previewText'] = objTools.toHTML(listings.previewText) />
			<cfset result['data']['details'] = objTools.toHTML(listings.details) />
			<cfset result['data']['terms'] = objTools.toHTML(listings.terms) />
			<cfset result['data']['created'] = objDates.fromEpoch(listings.created,'JSON') />

			<cfset result['data']['paymentPlan']['allowed'] = listings.paymentPlan />

			<cfset result['data']['rating']['average'] = ceiling(listings.ratingAvg) />

			<cfif listings.paymentPlan is 1>
				<cfset result['data']['paymentPlan']['paymentsTotal'] = listings.paymentPlanPayments />
				<cfset result['data']['paymentPlan']['paymentFrequency'] = listings.paymentPlanFrequencyName />
			</cfif>

			<cfset result['data']['location']['locationID'] = listings.location />
			<cfset result['data']['location']['name'] = listings.locationName />
			<cfset result['data']['location']['address1'] = listings.add1 />
			<cfset result['data']['location']['address2'] = listings.add2 />
			<cfset result['data']['location']['address3'] = listings.add3 />
			<cfset result['data']['location']['town'] = listings.town />
			<cfset result['data']['location']['county'] = listings.county />
			<cfset result['data']['location']['country'] = listings.country />
			<cfset result['data']['location']['countryName'] = listings.countryName />
			<cfset result['data']['location']['postcode'] = listings.postcode />
			<cfset result['data']['location']['hideAddress'] = listings.hideAddress />
			<cfset result['data']['location']['longitude'] = listings.longitude />
			<cfset result['data']['location']['latitude'] = listings.latitude />


			<cfquery name="images" datasource="startfly">
			SELECT 
			images.imagePath,
			images.groupID 
			FROM listingImages 
			INNER JOIN images ON listingImages.imageID = images.ID  
			WHERE listingImages.listingID = #listings.listingID#
			AND images.type = 'listing' 
			AND images.size = 'cover'
			ORDER BY listingImages.sortOrder
			</cfquery>

			<cfset result['data']['images'] = arrayNew(1) />

			<cfloop query="images">
				<cfset imgPath = 'https://beta.startfly.co.uk/images/library/' & images.imagePath />
				<cfset arrayAppend(result['data']['images'],imgPath) /> 	
			</cfloop>


			<cfif images.recordCount is 0>
					<cfset arrayAppend(result['data']['images'],replace(listings.imageURL,'tile-','cover-')) /> 	
			</cfif>


			<!--- a bit of pre work on the restrictions to get the right text for the listing icon row --->

			<!--- gender --->


			<cfquery name="restrictions" datasource="startfly">
			SELECT 
			listingRestrictions.optionID,
			restrictionOption.name
			FROM listingRestrictions 
			INNER JOIN restrictionOption ON listingRestrictions.optionID = restrictionOption.ID 
			WHERE listingRestrictions.listingID = #listings.listingID# 
			AND restrictionOption.ID IN (1,2)
			</cfquery>

			<cfset result['data']['iconText']['gender'] = listToArray(valueList(restrictions.name)) />

			<!--- min max age --->

			<cfquery name="restrictionGenre" datasource="startfly">
			SELECT 
			restrictionGenre.ID
			FROM restrictionGenre 
			ORDER BY restrictionGenre.ID DESC
			</cfquery>

			<cfloop query="restrictionGenre">

				<cfquery name="ageRestriction" datasource="startfly">
				SELECT minAge, maxAge 
				FROM listingRestrictionsAge 
				WHERE genre = #restrictionGenre.ID# 
				AND listingID = #listings.listingID# 
				ORDER BY listingRestrictionsAge.ID DESC 
				LIMIT 1
				</cfquery>
				
				<cfif ageRestriction.recordCount is 1>
					<cfset result['data']['ageMin'] = ageRestriction.minAge />
					<cfset result['data']['ageMax'] = ageRestriction.maxAge />
				</cfif>

			</cfloop>



			<cfquery name="cancellationPolicy" datasource="startfly">
			SELECT content 
			FROM cancellationPolicy 
			WHERE ID = '#listings.cancellationPolicy#'
			</cfquery>

			<cfset result['data']['cancellationPolicy'] = objTools.toHTML(cancellationPolicy.content) />

			<cfquery name="facilities" datasource="startfly">
			SELECT 
			facilities.SID,
			facilities.icon,
			facilities.name,
			locationFacilities.facility 
			FROM locationFacilities 
			INNER JOIN facilities ON locationFacilities.facility = facilities.ID
			WHERE locationID = #listings.location# 
			</cfquery>

			<cfset facilitiesArray = arrayNew(1) />
			<cfloop query="facilities">
				<cfset facilitiesArray[facilities.currentRow]['ID'] = facilities.sID />
				<cfset facilitiesArray[facilities.currentRow]['icon'] = facilities.icon />
				<cfset facilitiesArray[facilities.currentRow]['name'] = facilities.name />
			</cfloop>

			<cfset result['data']['location']['facilities'] = facilitiesArray />


			<cfset result['data']['categories'] = arrayNew(1) />

			<cfquery name="categories" datasource="startfly">
			SELECT 
			courseCategory.name,
			courseCategory.URL,
			courseCategory.secureID 
			FROM listingCategory 
			INNER JOIN courseCategory ON listingCategory.categoryID = courseCategory.ID 
			WHERE listingCategory.listingID = #listings.listingID# 
			</cfquery>


			<cfloop query="categories">
				<cfset  result['data']['categories'][categories.currentRow]['categoryID'] = categories.secureID />
				<cfset  result['data']['categories'][categories.currentRow]['pageURL'] = categories.URL />
				<cfset  result['data']['categories'][categories.currentRow]['categoryName'] = categories.name />
			</cfloop>


			<cfset result['data']['partner']['partnerID'] = listings.partnerSID />
			<cfset result['data']['partner']['created'] = objDates.fromEpoch(listings.partnerCreated,'JSON') />
			<cfif listings.useBusinessName is 0>
				<cfset result['data']['partner']['name'] = listings.firstname & ' ' & listings.surname />
				<cfset result['data']['partner']['firstname'] = listings.firstname />
			<cfelse>
				<cfset result['data']['partner']['name'] = listings.company />
				<cfset result['data']['partner']['firstname'] = listings.company />
			</cfif>
			<cfset result['data']['partner']['nickname'] = listings.nickname />
			<cfset result['data']['partner']['preview'] = listings.partnerPreview />
			<cfset result['data']['partner']['gender'] = listings.gender />
			<cfset result['data']['partner']['imageURL'] = 'https://beta.startfly.co.uk/images/partner/' & listings.avatar />

			<cfif 
				listings.webURL neq '' OR 
				listings.fbURL neq '' OR 
				listings.twitterURL neq '' OR 
				listings.youtubeURL neq '' OR 
				listings.instagramURL neq ''>
					
				<cfset result['data']['partner']['hasSocial'] = 1 />
			<cfelse>
				<cfset result['data']['partner']['hasSocial'] = 0 />
			</cfif>

			<cfset result['data']['partner']['webURL'] = listings.webURL />
			<cfset result['data']['partner']['fbURL'] = listings.fbURL />
			<cfset result['data']['partner']['twitterURL'] = listings.twitterURL />
			<cfset result['data']['partner']['instagramURL'] = listings.instagramURL />
			<cfset result['data']['partner']['youtubeURL'] = listings.youtubeURL />


			<cfquery name="occurrences" datasource="startfly">
			SELECT listingOccurrence.* 
			FROM listingOccurrence 
			WHERE listingID = #listings.listingID# 
			AND archive = 0
			ORDER BY starts
			</cfquery>

			<cfset ocArray = arrayNew(1) />

			<cfset result['data']['timesVary'] = 0 />


			<cfloop query="occurrences">
				<cfset ocArray[occurrences.currentRow]['ID'] = occurrences.sID />
				<cfset ocArray[occurrences.currentRow]['startDate'] = objDates.fromEpoch(occurrences.starts,'JSON') /> />
				<cfset ocArray[occurrences.currentRow]['endDate'] = objDates.fromEpoch(occurrences.ends,'JSON') /> />

				<cfset startDate = objDates.fromEpoch(occurrences.starts) />
				<cfset endDate = objDates.fromEpoch(occurrences.ends) />

				<cfset ocArray[occurrences.currentRow]['startHour'] = hour(startDate) />
				<cfset ocArray[occurrences.currentRow]['startMin'] = minute(startDate) />
				<cfset ocArray[occurrences.currentRow]['endHour'] = hour(endDate) />
				<cfset ocArray[occurrences.currentRow]['endMin'] = minute(endDate) />
				<cfset ocArray[occurrences.currentRow]['selected'] = 0 />
				<cfset ocArray[occurrences.currentRow]['guestsSelected'] = 0 />
				<cfset ocArray[occurrences.currentRow]['attending'] = [] />


				<cfset ocArray[occurrences.currentRow]['startDateID'] = occurrences.startDateID />
				<cfset ocArray[occurrences.currentRow]['startTimeID'] = occurrences.startTimeID />
				<cfset ocArray[occurrences.currentRow]['endDateID'] = occurrences.endDateID />
				<cfset ocArray[occurrences.currentRow]['endTimeID'] = occurrences.endTimeID />

				<cfset ocArray[occurrences.currentRow]['startDateFromDim'] = objDates.getDim(occurrences.startDateID,occurrences.startTimeID,'JSON') />
				<cfset ocArray[occurrences.currentRow]['endDateFromDim'] = objDates.getDim(occurrences.endDateID,occurrences.endTimeID,'JSON') />

				<!--- we want to see if the times vary so get the first date and then compare all against it --->
				<cfif occurrences.currentRow is 1>
					<cfset firstTimeVaryMatchString = hour(startDate) & minute(startDate) & hour(endDate) & minute(endDate) />
				</cfif>

				<cfset thisTimeVaryMatchString = hour(startDate) & minute(startDate) & hour(endDate) & minute(endDate) />

				<cfif firstTimeVaryMatchString neq thisTimeVaryMatchString>
					<cfset result['data']['timesVary'] = 1 />
				</cfif>
			</cfloop>

			<cfset result['data']['occurrences'] = ocArray />



			<cfquery name="restrictionGenre" datasource="startfly">
			SELECT 
			restrictionGenre.ID,
			restrictionGenre.sID,
			restrictionGenre.name 
			FROM restrictionGenre 
			ORDER BY restrictionGenre.sortOrder
			</cfquery>


			<cfset restrictionGenreArray = arrayNew(1) />
			<cfset rgCount = 0 />
			<cfloop query="restrictionGenre">


				<cfset restrictionCategoryArray = arrayNew(1) />
				<cfquery name="restrictionCategory" datasource="startfly">
				SELECT 
				restrictionCategory.ID,
				restrictionCategory.sID,
				restrictionCategory.name
				FROM restrictionCategory 
				WHERE restrictionCategory.genre = #restrictionGenre.ID# 
				</cfquery>


				<cfif restrictionCategory.recordCount gt 0>
					<cfset rgCount = rgCount + 1 />
					<cfset restrictionGenreArray[rgCount]['ID'] = restrictionGenre.sID />
					<cfset restrictionGenreArray[rgCount]['name'] = restrictionGenre.name />


				</cfif>

				<cfset rcCount = 0 />
				<cfloop query="restrictionCategory">

					<cfquery name="restrictions" datasource="startfly">
					SELECT 
					listingRestrictions.optionID,
					restrictionOption.sID,
					restrictionOption.name
					FROM listingRestrictions 
					INNER JOIN restrictionOption ON listingRestrictions.optionID = restrictionOption.ID 
					WHERE listingRestrictions.listingID = #listings.listingID# 
					AND restrictionOption.category = #restrictionCategory.ID# 
					ORDER BY restrictionOption.sortOrder
					</cfquery>

					<cfif restrictions.recordCount gt 0>
						<cfset rcCount = rcCount + 1 />

						<cfset restrictionCategoryArray[rcCount]['ID'] = restrictionCategory.sID />
						<cfset restrictionCategoryArray[rcCount]['name'] = restrictionCategory.name />
						
						<cfset restrictionsArray = arrayNew(1) />
						<cfloop query="restrictions">
							<cfset restrictionsArray[restrictions.currentRow]['ID'] = restrictions.sID />
							<cfset restrictionsArray[restrictions.currentRow]['name'] = restrictions.name />
						</cfloop>

						<cfset restrictionCategoryArray[rcCount]['restrictions'] = restrictionsArray />
					</cfif>

	
				</cfloop>

				<cfset restrictionGenreArray[rgCount]['categories'] = restrictionCategoryArray />

<!--- 				<cfloop index="d1" from="1" to="#arrayLen(restrictionGenreArray)#">
					<cfif arrayLen(restrictionGenreArray[d1]['categories']) is 0>
						<cfset arrayDeleteAt(restrictionGenreArray,d1) />
					</cfif>
				</cfloop>
 --->
			</cfloop>

			<cfset result['data']['restrictions'] = restrictionGenreArray />



			<cfquery name="kitCategory" datasource="startfly">
			SELECT 
			kitCategory.ID,
			kitCategory.name
			FROM kitCategory 
			ORDER BY kitCategory.name
			</cfquery>

			<cfset kitCategoryArray = arrayNew(1) />

			<cfloop query="kitCategory">
				<cfset kitCategoryArray[kitCategory.currentRow]['ID'] = kitCategory.ID />
				<cfset kitCategoryArray[kitCategory.currentRow]['name'] = kitCategory.name />

				<cfquery name="kits" datasource="startfly">
				SELECT 
				listingKit.kit,
				kit.name
				FROM listingKit 
				INNER JOIN kit ON listingKit.kit = kit.ID 
				WHERE listingKit.listingID = #listings.listingID# 
				AND kit.category = '#kitCategory.ID#' 
				ORDER BY kit.name
				</cfquery>

				<cfset kitsArray = arrayNew(1) />
				<cfloop query="kits">
					<cfset kitsArray[kits.currentRow]['ID'] = kits.kit />
					<cfset kitsArray[kits.currentRow]['name'] = kits.name />
				</cfloop>

				<cfset kitCategoryArray[kitCategory.currentRow]['kits'] = kitsArray />
			</cfloop>

			<cfset result['data']['kit'] = kitCategoryArray />




			<cfquery name="memberships" datasource="startfly">
			SELECT membershipID FROM 
			listingMemberships 
			WHERE listingID = #listings.listingID# 
			</cfquery>

			<cfloop query="memberships">
				<cfset result['data']['membership'][memberships.membershipID]['selected'] = true />
			</cfloop>



			<cfset whArray = arrayNew(1) />
			<cfset whCounter = 0 />
			<cfloop index="w1" from="1" to="7">
				<cfquery name="workingHours" datasource="startfly">
				SELECT workingHours.* 
				FROM workingHours 
				WHERE groupID = #listings.workingHours# 
				AND theDay = #w1#
				ORDER BY sortOrder 
				LIMIT 1
				</cfquery>

				<cfswitch expression="#w1#">
					<cfcase value="1">
						<cfset dayName = 'Monday' />
						<cfset dayOfWeek = 1 />
					</cfcase>
					<cfcase value="2">
						<cfset dayName = 'Tuesday' />
						<cfset dayOfWeek = 2 />
					</cfcase>
					<cfcase value="3">
						<cfset dayName = 'Wednesday' />
						<cfset dayOfWeek = 3 />
					</cfcase>
					<cfcase value="4">
						<cfset dayName = 'Thursday' />
						<cfset dayOfWeek = 4 />
					</cfcase>
					<cfcase value="5">
						<cfset dayName = 'Friday' />
						<cfset dayOfWeek = 5 />
					</cfcase>
					<cfcase value="6">
						<cfset dayName = 'Saturday' />
						<cfset dayOfWeek = 6 />
					</cfcase>
					<cfcase value="7">
						<cfset dayName = 'Sunday' />
						<cfset dayOfWeek = 0 />
					</cfcase>
				</cfswitch>


				<cfset tbArray = arrayNew(1) />

				<cfif workingHours.recordCount is 1>
					<cfset whCounter = whCounter + 1 />

					<cfset whArray[whCounter]['selected'] = 1 />
					<cfset whArray[whCounter]['name'] = dayName />
					<cfset whArray[whCounter]['dayOfWeek'] = dayOfWeek />
					<cfset whArray[whCounter]['ID'] = workingHours.theDay />
					<cfset tbArray[workingHours.currentRow]['startHour'] = workingHours.stHour />
					<cfset tbArray[workingHours.currentRow]['startMin'] = workingHours.stMin />
					<cfset tbArray[workingHours.currentRow]['endHour'] = workingHours.endHour />
					<cfset tbArray[workingHours.currentRow]['endMin'] = workingHours.endMin />
				</cfif>

				<cfif workingHours.recordCount gt 0>
					<cfset whArray[whCounter]['timeBlock'] = tbArray />
				</cfif>

			</cfloop>
			<cfset result['data']['workingHours'] = whArray />


			<cfset objTools.runtime('get', '/public/listings/{listingID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
