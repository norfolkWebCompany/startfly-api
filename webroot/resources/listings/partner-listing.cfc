<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/listings/{listingID}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="listings" datasource="startfly">
		SELECT 
		listing.*,
		courseCategory.name AS categoryName,
		locations.sID as locationSID,
		locations.name as locationName,
		locationTypes.name as locationTypeName,
		listingType.name as listingTypeName,
		partner.sID as partnerSID,
		emailResponse.sID as responseSID,
		cancellationPolicy.sID as cancellationPolicySID 
		FROM listing 
		INNER JOIN listingType ON listing.type = listingType.ID 
		LEFT JOIN locations ON listing.location = locations.ID 
		INNER JOIN locationTypes ON listing.locationType = locationTypes.ID 
		INNER JOIN partner ON listing.partnerID = partner.ID 
		LEFT JOIN emailResponse ON listing.responseID = emailResponse.ID 
		LEFT JOIN cancellationPolicy ON listing.cancellationPolicy = cancellationPolicy.ID 
		LEFT JOIN courseCategory ON listing.categoryID = courseCategory.ID
		WHERE listing.partnerID = #internalPartnerID# 
		AND listing.sID = '#arguments.listingID#' 
		</cfquery>



		<cfif listings.recordCount gt 0>


			<cfif listings.responseSID is ''>
				<cfset emailResponseSID = 0 />
			<cfelse>
				<cfset emailResponseSID = listings.responseSID />
			</cfif>
			
		
			<cfset duration = objTools.minutesTohours(listings.duration) />
			<cfset intervalBreak = objTools.minutesTohours(listings.intervalBreak) />

			<cfset result['data']['listingID'] = listings.sID />
			<cfset result['data']['partnerID'] = listings.partnerSID />
			<cfset result['data']['name'] = listings.name />
			<cfset result['data']['type'] = listings.type />
			<cfset result['data']['membersOnly'] = listings.membersOnly />
			<cfset result['data']['occurrenceType'] = listings.occurrenceType />
			<cfset result['data']['category']['ID'] = listings.categoryID />
			<cfset result['data']['category']['name'] = listings.categoryName />
			<cfset result['data']['imageURL'] = listings.imageURL />
			<cfset result['data']['previewText'] = listings.previewText />
			<cfset result['data']['details'] = listings.details />
			<cfset result['data']['indoorOutdoor'] = listings.indoorOutdoor />
			<cfset result['data']['location'] = listings.locationSID />
			<cfset result['data']['locationName'] = listings.locationName />
			<cfset result['data']['locationType'] = listings.locationType />
			<cfset result['data']['locationTypeName'] = listings.locationTypeName />
			<cfset result['data']['maxTravelMiles'] = listings.maxTravelMiles />
			<cfset result['data']['travelFee'] = listings.travelFee />
			<cfset result['data']['travelFeePerMile'] = listings.travelFeePerMile />
			<cfset result['data']['ageMin'] = listings.ageMin />
			<cfset result['data']['ageMax'] = listings.ageMax />
			<cfset result['data']['cancellationPolicy'] = listings.cancellationPolicySID />
			<cfset result['data']['termsText'] = listings.terms />
			<cfset result['data']['responseID'] = emailResponseSID />
			<cfset result['data']['cost'] = listings.cost />
			<cfset result['data']['multiBuy'] = listings.multiBuy />
			<cfset result['data']['multiBuyCost'] = listings.multiBuyCost />
			<cfset result['data']['multiBuyQty'] = listings.multiBuyQty/>
			<cfset result['data']['pricingModel'] = listings.pricingModel />
			<cfset result['data']['minAttendees'] = listings.minAttendees />
			<cfset result['data']['maxAttendees'] = listings.capacity />
			<cfset result['data']['minBookingQty'] = listings.minBookingQty />
			<cfset result['data']['splitOccurrences'] = listings.splitOccurrences />
			<cfset result['data']['duration']['hour'] = duration.hour />
			<cfset result['data']['duration']['min'] = duration.min />
			<cfset result['data']['intervalBreak']['hour'] = intervalBreak.hour />
			<cfset result['data']['intervalBreak']['min'] = intervalBreak.min />

			<cfset result['data']['rating'] = listings.rating />
			<cfset result['data']['capacity'] = listings.capacity />
			<cfset result['data']['featured'] = listings.featured />
			<cfset result['data']['created'] = objDates.fromEpoch(listings.created,'JSON') />

			<cfset result['data']['paymentPlan']['allowed'] = listings.paymentPlan />
			<cfset result['data']['paymentPlan']['totalPayments'] = listings.paymentPlanPayments />
			<cfset result['data']['paymentPlan']['frequency'] = listings.paymentPlanFrequency />
			<cfset result['data']['workingHoursGroup'] = listings.workingHours />

			<cfquery name="images" datasource="startfly">
			SELECT 
			listingImages.ID,
			images.imagePath,
			images.groupID 
			FROM listingImages 
			INNER JOIN images ON listingImages.imageID = images.ID  
			WHERE listingImages.listingID = #internalListingID# 
			AND images.type = 'listing' 
			AND images.size = 'cover'
			ORDER BY listingImages.sortOrder
			</cfquery>

			<cfset imagesArray = arrayNew(1) />

			<cfloop query="images">
				<cfset imagesArray[images.currentRow]['ID'] = images.ID />
				<cfset imagesArray[images.currentRow]['imagePath'] = 'https://beta.startfly.co.uk/images/library/' & images.imagePath />
				<cfset imagesArray[images.currentRow]['selected'] = 1 />
			</cfloop>

			<cfset result['data']['images'] = imagesArray /> 




			<cfquery name="occurrences" datasource="startfly">
			SELECT listingOccurrence.* 
			FROM listingOccurrence 
			WHERE listingID = #internalListingID# 
			AND archive = 0
			ORDER BY starts
			</cfquery>

			<cfset ocArray = arrayNew(1) />

			<cfloop query="occurrences">

				<cfset occurrenceStarts = objDates.fromEpoch(occurrences.starts) />
				<cfset occurrenceEnds = objDates.fromEpoch(occurrences.ends) />

				<cfset ocArray[occurrences.currentRow]['startDate'] = objDates.toJSON(occurrenceStarts) />
				<cfset ocArray[occurrences.currentRow]['endDate'] = objDates.toJSON(occurrenceEnds) />
				<cfset ocArray[occurrences.currentRow]['startHour'] = hour(occurrenceStarts) />
				<cfset ocArray[occurrences.currentRow]['startMin'] = minute(occurrenceStarts) />
				<cfset ocArray[occurrences.currentRow]['endHour'] = hour(occurrenceEnds) />
				<cfset ocArray[occurrences.currentRow]['endMin'] = minute(occurrenceEnds) />
				<cfset ocArray[occurrences.currentRow]['startDateID'] = occurrences.startDateID />
				<cfset ocArray[occurrences.currentRow]['startTimeID'] = occurrences.startTimeID />
				<cfset ocArray[occurrences.currentRow]['endDateID'] = occurrences.endDateID />
				<cfset ocArray[occurrences.currentRow]['endTimeID'] = occurrences.endTimeID />
			</cfloop>

			<cfset result['data']['occurrences'] = ocArray />

			<cfquery name="genre" datasource="startfly">
			SELECT 
			restrictionGenre.*
			FROM restrictionGenre 
			ORDER BY restrictionGenre.sortOrder
			</cfquery>

			<cfset genreArray = arrayNew(1) />

			<cfloop query="genre">
				<cfset genreArray[genre.currentRow]['ID'] = genre.sID />
				<cfset genreArray[genre.currentRow]['name'] = genre.name />
				<cfset genreArray[genre.currentRow]['maxAge'] = genre.maxAge />
				<cfset genreArray[genre.currentRow]['minAgeSelected'] = genre.minAge />
				<cfset genreArray[genre.currentRow]['maxAgeSelected'] = genre.maxAge />
				<cfset genreArray[genre.currentRow]['selected'] = genre.selected />
				<cfset genreArray[genre.currentRow]['score'] = genre.score />

				<cfquery name="ageCheck" datasource="startfly">
				SELECT minAge, maxAge 
				FROM listingRestrictionsAge 
				WHERE listingID = #internalListingID# 
				AND genre = #genre.ID# 
				LIMIT 1
				</cfquery>

				<cfif ageCheck.recordCount is 1>
					<cfset genreArray[genre.currentRow]['minAgeSelected'] = ageCheck.minAge />
					<cfset genreArray[genre.currentRow]['maxAgeSelected'] = ageCheck.maxAge />
				</cfif>

				<cfquery name="restrictionCategories" datasource="startfly">
				SELECT 
				restrictionCategory.ID,
				restrictionCategory.sID,
				restrictionCategory.name,
				restrictionCategory.description,
				restrictionCategory.collapsed,
				restrictionCategory.selected 
				FROM restrictionCategory 
				WHERE genre = #genre.ID#
				ORDER BY restrictionCategory.sortOrder
				</cfquery>

				<cfset categoryArray = arrayNew(1) />
				<cfloop query="restrictionCategories">
					<cfset categoryArray[restrictionCategories.currentRow]['ID']  = restrictionCategories.sID />
					<cfset categoryArray[restrictionCategories.currentRow]['name']  = restrictionCategories.name />
					<cfset categoryArray[restrictionCategories.currentRow]['description']  = restrictionCategories.description />
					<cfset categoryArray[restrictionCategories.currentRow]['collapsed']  = restrictionCategories.collapsed />
					<cfset categoryArray[restrictionCategories.currentRow]['selected']  = restrictionCategories.selected />


					<cfquery name="options" datasource="startfly">
					SELECT 
					restrictionOption.ID,
					restrictionOption.SID,
					restrictionOption.name  
					FROM restrictionOption 
					WHERE category = #restrictionCategories.ID#
					AND status = 1 
					AND Deleted = 0 
					ORDER BY restrictionOption.sortOrder
					</cfquery>

					<cfset optionsArray = arrayNew(1) />
					<cfloop query="options">
						<cfset optionsArray[options.currentRow]['ID'] = options.sID />
						<cfset optionsArray[options.currentRow]['name'] = options.name />

						<cfquery name="optionCheck" datasource="startfly">
						SELECT optionID 
						FROM listingRestrictions 
						WHERE listingID = #internalListingID# 
						AND optionID = #options.ID#
						</cfquery>

						<cfif optionCheck.recordCount is 0>
							<cfset optionsArray[options.currentRow]['selected'] = 0 />
						<cfelse>
							<cfset optionsArray[options.currentRow]['selected'] = 1 />
							<cfset genreArray[genre.currentRow]['selected'] = 1 />
						</cfif>


					</cfloop>
					<cfset categoryArray[restrictionCategories.currentRow]['options'] = optionsArray />


				</cfloop>
				<cfset genreArray[genre.currentRow]['categories'] = categoryArray />


			</cfloop>

			<cfset result['data']['restrictions'] = genreArray />



<!--- 			<cfquery name="restrictions" datasource="startfly">
			SELECT 
			restrictionOption.sID
			FROM listingRestrictions 
			INNER JOIN restrictionOption ON listingRestrictions.optionID = restrictionOption.ID
			WHERE listingRestrictions.listingID = #listings.ID# 
			</cfquery>

			<cfloop query="restrictions">
				<cfset result['data']['restrictions'][restrictions.sID]['selected'] = true />
			</cfloop>
 --->




			<cfquery name="kits" datasource="startfly">
			SELECT kit.sID 
			FROM listingKit 
			INNER JOIN kit ON listingKit.kit = kit.ID  
			WHERE listingID = #listings.ID# 
			</cfquery>

			<cfloop query="kits">
				<cfset result['data']['kit'][kits.sID]['selected'] = true />
			</cfloop>


			<cfquery name="memberships" datasource="startfly">
			SELECT 
			memberships.ID,
			memberships.sID,
			memberships.name
			FROM memberships 
			WHERE memberships.partnerID = #internalPartnerID# 
			</cfquery>

			<cfset membershipArray = arrayNew(1) />

			<cfset hasMemberships = 0 />

			<cfloop query="memberships">
				<cfset membershipArray[memberships.currentRow]['membershipID'] = memberships.sID />
				<cfset membershipArray[memberships.currentRow]['name'] = memberships.name />

					<cfquery name="currentMemberships" datasource="startfly">
					SELECT 
					listingMemberships.*
					FROM listingMemberships  
					WHERE listingMemberships.membershipID = #memberships.ID# 
					AND listingMemberships.listingID = #internalListingID# 
					LIMIT 1
					</cfquery>

					<cfif currentMemberships.recordCount is 1>
						<cfset membershipArray[memberships.currentRow]['freeEntry'] = currentMemberships.freeEntry />
						<cfset membershipArray[memberships.currentRow]['limitedFreeEntryQty'] = currentMemberships.freeEntryQty />
						<cfset membershipArray[memberships.currentRow]['limitedFreeEntryPeriod'] = currentMemberships.freeEntryPeriod />
						<cfset membershipArray[memberships.currentRow]['discountedEntry'] = currentMemberships.discountedEntry />
						<cfset membershipArray[memberships.currentRow]['discountedCost'] = currentMemberships.discountedEntryCost />
						<cfset membershipArray[memberships.currentRow]['selected'] = 1 />
	
						<cfset hasMemberships = 1 />

					<cfelse>
						<cfset membershipArray[memberships.currentRow]['freeEntry'] = 0 />
						<cfset membershipArray[memberships.currentRow]['limitedFreeEntryQty'] = 0 />
						<cfset membershipArray[memberships.currentRow]['limitedFreeEntryPeriod'] = '' />
						<cfset membershipArray[memberships.currentRow]['discountedEntry'] = 0 />
						<cfset membershipArray[memberships.currentRow]['discountedCost'] = 0 />
						<cfset membershipArray[memberships.currentRow]['selected'] = 0 />
					</cfif>
			</cfloop>




			<cfset result['data']['memberships'] = membershipArray />
			<cfset result['data']['allowMembers'] = hasMemberships />
			<cfset result['data']['membersOnly'] =  listings.membersOnly />

			<cfset whArray = arrayNew(1) />

			<cfloop index="w1" from="1" to="7">
				<cfquery name="workingHours" datasource="startfly">
				SELECT workingHours.* 
				FROM workingHours 
				WHERE groupID = '#listings.workingHours#' 
				AND theDay = #w1#
				ORDER BY sortOrder 
				LIMIT 1
				</cfquery>

				<cfswitch expression="#w1#">
					<cfcase value="1"><cfset dayName = 'Monday' /></cfcase>
					<cfcase value="2"><cfset dayName = 'Tuesday' /></cfcase>
					<cfcase value="3"><cfset dayName = 'Wednesday' /></cfcase>
					<cfcase value="4"><cfset dayName = 'Thursday' /></cfcase>
					<cfcase value="5"><cfset dayName = 'Friday' /></cfcase>
					<cfcase value="6"><cfset dayName = 'Saturday' /></cfcase>
					<cfcase value="7"><cfset dayName = 'Sunday' /></cfcase>
				</cfswitch>

				<cfset tbArray = arrayNew(1) />

				<cfif workingHours.recordCount is 0>
					<cfset whArray[w1]['selected'] = 0 />
					<cfset whArray[w1]['name'] = dayName />
					<cfset whArray[w1]['ID'] = w1 />
					<cfset tbArray[1]['startHour'] = 0 />
					<cfset tbArray[1]['startMin'] = 0 />
					<cfset tbArray[1]['endHour'] = 0 />
					<cfset tbArray[1]['endMin'] = 0 />
				<cfelse>
					<cfset whArray[w1]['selected'] = 1 />
					<cfset whArray[w1]['name'] = dayName />
					<cfset whArray[w1]['ID'] = workingHours.theDay />
					<cfset tbArray[workingHours.currentRow]['startHour'] = workingHours.stHour />
					<cfset tbArray[workingHours.currentRow]['startMin'] = workingHours.stMin />
					<cfset tbArray[workingHours.currentRow]['endHour'] = workingHours.endHour />
					<cfset tbArray[workingHours.currentRow]['endMin'] = workingHours.endMin />
				</cfif>
				<cfset whArray[w1]['timeBlock'] = tbArray />

			</cfloop>
			<cfset result['data']['workingHours'] = whArray />


			<cfquery name="expenses" datasource="startfly">
			SELECT expenses.* 
			FROM expenses 
			WHERE status = 1 
			ORDER BY sortOrder
			</cfquery>

			<cfset expensesArray = arrayNew(1) />

			<cfloop query="expenses">

				<cfquery name="expense" datasource="startfly">
				SELECT 
				listingExpenses.* 
				FROM listingExpenses 
				WHERE listingID = #internalListingID#
				AND expenseID = #expenses.ID#
				</cfquery>

				<cfif expense.recordCount is 0>
					<cfset expensesArray[expenses.currentRow]['ID'] = expenses.sID />
					<cfset expensesArray[expenses.currentRow]['name'] = expenses.name />
					<cfset expensesArray[expenses.currentRow]['description'] = expenses.description />
					<cfset expensesArray[expenses.currentRow]['expenseType'] = 1 />
					<cfset expensesArray[expenses.currentRow]['expenseDuration'] = 1 />
					<cfset expensesArray[expenses.currentRow]['value'] = 0 />
				<cfelse>
					<cfset expensesArray[expenses.currentRow]['ID'] = expenses.sID />
					<cfset expensesArray[expenses.currentRow]['name'] = expenses.name /> />
					<cfset expensesArray[expenses.currentRow]['description'] = expenses.description />
					<cfset expensesArray[expenses.currentRow]['expenseType'] = expense.expenseType />
					<cfset expensesArray[expenses.currentRow]['expenseDuration'] = expense.expenseDuration />
					<cfset expensesArray[expenses.currentRow]['value'] = expense.value />
				</cfif>

			</cfloop>

			<cfset result['data']['expenses'] = expensesArray />




<!--- 			<cfset kitArray = arrayNew(1) />

			<cfloop query="kit">

				<cfquery name="item" datasource="startfly">
				SELECT listingKit.* 
				FROM listingKit 
				WHERE listingID = '#arguments.listingID#' 
				AND kit = '#kit.ID#'
				</cfquery>

				<cfif item.recordCount is 0>
					<cfset kitArray[kit.currentRow]['ID'] = kit.ID />
					<cfset kitArray[kit.currentRow]['name'] = kit.name />
					<cfset kitArray[kit.currentRow]['category']['ID'] = kit.category />
					<cfset kitArray[kit.currentRow]['category']['name'] = kit.categoryName />
					<cfset kitArray[kit.currentRow]['required'] = 0 />
					<cfset kitArray[kit.currentRow]['provided'] = 0 />
				<cfelse>
					<cfset kitArray[kit.currentRow]['ID'] = kit.ID />
					<cfset kitArray[kit.currentRow]['name'] = kit.name />
					<cfset kitArray[kit.currentRow]['category']['ID'] = kit.category />
					<cfset kitArray[kit.currentRow]['category']['name'] = kit.categoryName />
					<cfset kitArray[kit.currentRow]['required'] = 1 />
					<cfset kitArray[kit.currentRow]['provided'] = item.provided />
				</cfif>

			</cfloop>

			<cfset result['data']['kit'] = kitArray />
 --->



		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/partner/{partnerID}/listings/{listingID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>




	<cffunction name="post" access="public" output="false">

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset objAccum = createObject('component','/resources/private/accum') />


		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset internalCancellationPolicy = objTools.internalID('cancellationPolicy',arguments.cancellationPolicy) />


		<cfif arguments.location neq ''>
			<cfset internalLocationID = objTools.internalID('locations',arguments.location) />
		<cfelse>
			<cfset internalLocationID = 0 />
		</cfif>

		<cfif arguments.responseID neq '' and arguments.responseID neq 0>
			<cfset internalResponseID = objTools.internalID('emailResponse',arguments.responseID) />
		<cfelse>
			<cfset internalResponseID = 0 />
		</cfif>

		<cfset sessionDuration = objTools.hoursToMinutes(arguments.duration.hour,arguments.duration.min) />
		<cfset intervalBreak = objTools.hoursToMinutes(arguments.intervalBreak.hour,arguments.intervalBreak.min) />


		<cfquery datasource="startfly">
		UPDATE listing SET 
		name = '#arguments.name#',
		type = #arguments.type#,
		categoryID = #arguments.category.ID#,
		occurrenceType = #arguments.occurrenceType#,
		membersOnly = #arguments.membersOnly#,
		previewText = '#arguments.previewText#',
		details = '#arguments.details#',
		imageURL = '#replace(arguments.imageURL,"listing/tmp/","listing/")#',
		location = #internalLocationID#,
		locationType = #arguments.locationType#,
		maxTravelMiles = #arguments.maxTravelMiles#,
		travelFee = #arguments.travelFee#,
		travelFeePerMile = #arguments.travelFeePerMile#,
		cancellationPolicy = #internalCancellationPolicy#,
		responseID = #internalResponseID#,
		cost = #arguments.cost#,
		minAttendees = #arguments.minAttendees#,
		capacity = #arguments.maxAttendees#,
		minBookingQty = #arguments.minBookingQty#,
		splitOccurrences = #arguments.splitOccurrences#,
		duration = #sessionDuration#,
		intervalBreak = #intervalBreak#,
		paymentPlan = #arguments.paymentPlan.allowed#,
		paymentPlanPayments = #arguments.paymentPlan.totalPayments#,
		paymentPlanFrequency = #arguments.paymentPlan.frequency#,
		terms = '#arguments.termsText#',
		indoorOutdoor = #arguments.indoorOutdoor#,
		pricingModel = #arguments.pricingModel#,
		multiBuy = #arguments.multiBuy#,
		multiBuyQty = #arguments.multiBuyQty#,
		multiBuyCost = #arguments.multiBuyCost#
		WHERE sID = '#arguments.listingID#'
		</cfquery>

		<cfquery datasource="startfly">
		UPDATE listingOccurrence SET 
		archive = 1 
		WHERE listingID = #internalListingID#
		</cfquery>


		<cfloop index="o1" from="1" to="#arrayLen(arguments.occurrences)#">


			<cfset datePart = listFirst(arguments.occurrences[o1].startDate,'T') />
		
			<cfset startYear = listGetAt(datePart,1,'-') />
			<cfset startMonth = listGetAt(datePart,2,'-') />
			<cfset startDay = listGetAt(datePart,3,'-') />

			<cfset startDate = createDateTime(
									startYear,
									startMonth,
									startDay,
									arguments.occurrences[o1].startHour,
									arguments.occurrences[o1].startMin,
									0
								) />

			<cfset datePart = listFirst(arguments.occurrences[o1].startDate,'T') />

			<cfset endYear = listGetAt(datePart,1,'-') />
			<cfset endMonth = listGetAt(datePart,2,'-') />
			<cfset endDay = listGetAt(datePart,3,'-') />

			<cfset endDate = createDateTime(
									endYear,
									endMonth,
									endDay,
									arguments.occurrences[o1].endHour,
									arguments.occurrences[o1].endMin,
									0
								) />


			<cfset starts = objDates.toEpoch(startDate,'','-') />
			<cfset ends = objDates.toEpoch(endDate,'','-') />

	        <cfset startDim = objDates.setDim(
	        	{
	        		date = datePart,
	        		hour = arguments.occurrences[o1].startHour,
	        		minute = arguments.occurrences[o1].startMin
	        	}
	        ) />
	        <cfset endDim = objDates.setDim(
	        	{
	        		date = datePart,
	        		hour = arguments.occurrences[o1].endHour,
	        		minute = arguments.occurrences[o1].endMin
	        	}
	        ) />




			<cfset occurrenceID = objAccum.newID('secureIDPrefix') />
			<cfset occurrenceSID = objTools.secureID() />

			<cfquery datasource="startfly">
			INSERT INTO listingOccurrence (
			ID,
			sID,
			partnerID,
			listingID,
			type,
			starts,
			ends,
			startDateID,
			startTimeID,
			endDateID,
			endTimeID,
			created
			) VALUES (
			#occurrenceID#,
			'#occurrenceSID#',
			#internalPartnerID#,
			#internalListingID#,
			#arguments.occurrenceType#,
			#starts#,
			#ends#,
			#startDim.dateID#,
			#startDim.timeID#,
			#endDim.dateID#,
			#endDim.timeID#,
			#objDates.toEpoch(now())#
			)
			</cfquery>

		</cfloop>

		<cfquery datasource="startfly">
		DELETE FROM listingCategory 
		WHERE listingID = #internalListingID#
		</cfquery>

		<cfset categoreyIndexID = objAccum.newID('secureIDPrefix') />
		<cfset categoreyIndexSID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO listingCategory (
		ID,
		sID,
		listingID,
		partnerID,
		categoryID,
		created
		) VALUES (
		#categoreyIndexID#,
		'#categoreyIndexSID#',
		#internalListingID#,
		#internalPartnerID#,
		#arguments.category.ID#,
		NOW()
		)
		</cfquery>


 		<cfquery datasource="startfly">
	 	DELETE FROM listingRestrictions 
	 	WHERE listingID = #internalListingID#
 		</cfquery>

 		<cfquery datasource="startfly">
	 	DELETE FROM listingRestrictionsAge 
	 	WHERE listingID = #internalListingID#
 		</cfquery>


		<cfloop index="i1" from="1" to="#arrayLen(arguments.restrictions)#">
			<cfif arguments.restrictions[i1].selected is 1 >

				<cfset internalGenreID = objTools.internalID('restrictionGenre',arguments.restrictions[i1].ID) />

				<cfquery datasource="startfly">
				INSERT INTO listingRestrictionsAge (
				listingID,
				genre,
				minAge,
				maxAge
				) VALUES (
				#internalListingID#,
				#internalGenreID#,
				#arguments.restrictions[i1].minAgeSelected#,
				#arguments.restrictions[i1].maxAgeSelected#
				)
				</cfquery>

				<cfloop index="i2" from="1" to="#arrayLen(arguments.restrictions[i1].categories)#">
					<cfloop index="i3" from="1" to="#arrayLen(arguments.restrictions[i1].categories[i2].options)#">
						<cfif arguments.restrictions[i1].categories[i2].options[i3].selected is 1>
							<cfset internalRestrictionOptionID = objTools.internalID('restrictionOption',arguments.restrictions[i1].categories[i2].options[i3].ID) />

							<cfquery datasource="startfly">
								INSERT INTO listingRestrictions (
								listingID,
								sID,
								optionID
								) VALUES (
								#internalListingID#,
								'#objTools.secureID()#',
								#internalRestrictionOptionID#
								)
							</cfquery>
						</cfif>
					</cfloop>
				</cfloop>
			</cfif>
		</cfloop>








 		<cfquery datasource="startfly">
	 	DELETE FROM listingKit 
	 	WHERE listingID = #internalListingID#
 		</cfquery>

		<cfif isDefined("arguments.kit")>
			<cfloop index="i1" list="#structKeyList(arguments.kit)#">
				<cfif arguments.kit[i1]['selected'] is 1 >
					<cfset internalKitID = objTools.internalID('kit',i1) />
					<cfquery datasource="startfly">
						INSERT INTO listingKit (
						listingID,
						kit
						) VALUES (
						#internalListingID#,
						#internalKitID#
						)
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>


 		<cfquery datasource="startfly">
	 	DELETE FROM listingMemberships 
	 	WHERE listingID = #internalListingID#
 		</cfquery>

		<cfif isDefined("arguments.memberships")>
			

			<cfloop index="i1" from="1" to="#arrayLen(arguments.memberships)#">
				
				<cfif arguments.memberships[i1]['selected'] is 1 >
					<cfset internalMembershipID = objTools.internalID('memberships',arguments.memberships[i1].membershipID) />

					<cfif arguments.memberships[i1].limitedFreeEntryPeriod is ''>
						<cfset memFreeEntryPeriod = 0 />
					<cfelse>
						<cfset memFreeEntryPeriod = arguments.memberships[i1].limitedFreeEntryPeriod />
					</cfif>

					<cfquery datasource="startfly">
						INSERT INTO listingMemberships (
						sID,
						listingID,
						membershipID,
						discountedEntry,
						discountedEntryCost,
						freeEntry,
						freeEntryQty,
						freeEntryPeriod
						) VALUES (
						'#objTools.secureID()#',
						#internalListingID#,
						#internalMembershipID#,
						#arguments.memberships[i1].discountedEntry#,
						#arguments.memberships[i1].discountedCost#,
						#arguments.memberships[i1].freeEntry#,
						#arguments.memberships[i1].limitedFreeEntryQty#,
						#memFreeEntryPeriod#
						)
					</cfquery>
				</cfif>

			</cfloop>

		</cfif>


 		<cfquery datasource="startfly">
	 	DELETE FROM listingExpenses 
	 	WHERE listingID = #internalListingID#
 		</cfquery>

		<cfloop index="i1" from="1" to="#arrayLen(arguments.expenses)#">
			
			<cfif arguments.expenses[i1]['value'] gt 0 >
				<cfset internalExpensesID = objTools.internalID('expenses',arguments.expenses[i1]['ID']) />
				<cfquery datasource="startfly">
					INSERT INTO listingExpenses (
					sID,
					partnerID,
					listingID,
					expenseID,
					expenseType,
					expenseDuration,
					value
					) VALUES (
					'#objTools.secureID()#',
					#internalPartnerID#,
					#internalListingID#,
					#internalExpensesID#,
					#arguments.expenses[i1]['expenseType']#,
					#arguments.expenses[i1]['expenseDuration']#,
					#arguments.expenses[i1]['value']#
					)
				</cfquery>
			</cfif>

		</cfloop>



		<cfquery datasource="startfly">
		UPDATE workingHours SET archived = 1 WHERE groupID = #arguments.workingHoursGroup#
		</cfquery>


		<cfset sortOrder = 0 />
		<cfset workingHoursGroupID = objAccum.newID('secureIDPrefix') />
		<cfset allocatedWorkingHours = 0 />

		<cfloop index="w1" from="1" to="#arrayLen(arguments.workingHours)#">
			<cfif arguments.workingHours[w1].selected is 1>
				

				<cfloop index="b1" from="1" to="#arrayLen(arguments.workingHours[w1]['timeBlock'])#">

					<cfset allocatedWorkingHours = 1 />

					<cfset workingHoursID = objAccum.newID('secureIDPrefix') />
					<cfset workingHoursSID = objTools.secureID() />

					<cfset sortOrder = sortOrder + 1 />


					<cfquery datasource="startfly">
					INSERT INTO workingHours (
					ID,
					sID,
					groupID,
					partnerID,
					theDay,
					stHour,
					stMin,
					endHour,
					endMin,
					sortOrder
					) VALUES (
					#workingHoursID#,
					'#workingHoursSID#',
					#workingHoursGroupID#,
					#internalPartnerID#,
					#arguments.workingHours[w1]['ID']#,
					#arguments.workingHours[w1]['timeBlock'][b1]['startHour']#,
					#arguments.workingHours[w1]['timeBlock'][b1]['startMin']#,
					#arguments.workingHours[w1]['timeBlock'][b1]['endHour']#,
					#arguments.workingHours[w1]['timeBlock'][b1]['endMin']#,
					#sortOrder#
					)
					</cfquery>
				</cfloop>
			</cfif>

		</cfloop>

		<cfif allocatedWorkingHours is 1>
			<cfquery datasource="startfly">
			UPDATE listing 
			SET workingHours = #workingHoursGroupID# 
			WHERE ID = #internalListingID#
			</cfquery>
		</cfif>




		<cfquery datasource="startfly">
		DELETE FROM listingImages 
		WHERE listingID = #internalListingID#
		</cfquery>


		<cfloop index="img1" from="1" to="#arrayLen(arguments.images)#">

	    	<cfquery datasource="startfly">
		    INSERT INTO listingImages (
		    listingID,
		    imageID,
		    created
		    ) VALUES (
		    #internalListingID#,
		    #arguments.images[img1].ID#,
		    NOW()
		    ) 
	    	</cfquery>
    	</cfloop>




		<cfset result['data']['listingID'] = arguments.listingID />
		<cfset result['data']['status'] = 1 />
		<cfset result['data']['arguments'] = arguments />

		<cfset objTools.runtime('post', '/partner/{partnerID}/listings/{listingID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


	<cffunction name="delete" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="listingID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE listing 
		SET deleted = 1 
		WHERE sID = '#arguments.listingID#'
		</cfquery>

		<cfset result['data']['listingID'] = arguments.listingID />

		<cfset objTools.runtime('delete', '/partner/{partnerID}/listings/{listingID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
