<cfcomponent extends="taffy.core.resource" taffy:uri="/listing" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">

		<cfset objAccum = createObject('component','/resources/private/accum') />
		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset sTime = getTickCount() />

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

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset listingID = objAccum.newID('secureIDPrefix') />
		<cfset listingSID = objTools.secureID() />

		<cfif arguments.maxTravelMiles is ''>
			<cfset arguments.maxTravelMiles = 0 />
		</cfif>

		<cfset sessionDuration = objTools.hoursToMinutes(arguments.duration.hour,arguments.duration.min) />
		<cfset intervalBreak = objTools.hoursToMinutes(arguments.intervalBreak.hour,arguments.intervalBreak.min) />

		<cfset URLFix = objTools.cleanURL(arguments.name) />


		<cfquery datasource="startfly">
		INSERT INTO listing (
		ID,
		sID,
		partnerID,
		categoryID,
		type,
		occurrenceType,
		splitOccurrences,
		name,
		url,
		membersOnly,
		previewText,
		details,
		imageURL,
		location,
		locationType,
		maxTravelMiles,
		travelFee,
		travelFeePerMile,
		cancellationPolicy,
		responseID,
		cost,
		pricingModel,
		multiBuy,
		multiBuyQty,
		multiBuyCost,
		minAttendees,
		capacity,
		minBookingQty,
		duration,
		intervalBreak,
		paymentPlan,
		paymentPlanPayments,
		paymentPlanFrequency,
		indoorOutdoor,
		terms,
		status,
		created
		) VALUES (
		#listingID#,
		'#listingSID#',
		#internalPartnerID#,
		#arguments.category.ID#,
		#arguments.type#,
		#arguments.occurrenceType#,
		#arguments.splitOccurrences#,
		'#arguments.name#',
		'#URLFix.cleanURL#',
		#membersOnly#,
		'#arguments.previewText#',
		'#arguments.details#',
		'#arguments.imageURL#',
		#internalLocationID#,
		#arguments.locationType#,
		#arguments.maxTravelMiles#,
		#arguments.travelFee#,
		#arguments.travelFeePerMile#,
		#internalCancellationPolicy#,
		#internalResponseID#,
		#arguments.cost#,
		#arguments.pricingModel#,
		#arguments.multiBuy#,
		#arguments.multiBuyQty#,
		#arguments.multiBuyCost#,
		#arguments.minAttendees#,
		#arguments.maxAttendees#,
		#arguments.minBookingQty#,
		#sessionDuration#,
		#intervalBreak#,
		#arguments.paymentPlan.allowed#,
		#arguments.paymentPlan.totalPayments#,
		#arguments.paymentPlan.frequency#,
		#arguments.indoorOutdoor#,
		'#arguments.termsText#',
		1,
		#objDates.toEpoch(now())#
		)
		</cfquery>


		<cfloop index="o1" from="1" to="#arrayLen(arguments.occurrences)#">
			<cfset occurrenceID = objAccum.newID('secureIDPrefix') />
			<cfset occurrenceSID = objTools.secureID() />
	


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


			<cfswitch expression="#arguments.occurrenceType#">
				<cfcase value="1">
					<cfset datePart = listFirst(arguments.occurrences[o1].startDate,'T') />

					<cfset endYear = listGetAt(datePart,1,'-') />
					<cfset endMonth = listGetAt(datePart,2,'-') />
					<cfset endDay = listGetAt(datePart,3,'-') />
				</cfcase>
				<cfdefaultcase>
					<cfset datePart = listFirst(arguments.occurrences[o1].startDate,'T') />

					<cfset endYear = listGetAt(datePart,1,'-') />
					<cfset endMonth = listGetAt(datePart,2,'-') />
					<cfset endDay = listGetAt(datePart,3,'-') />

				</cfdefaultcase>
			</cfswitch>

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

			<cfset dStartDate = createDate(
									startYear,
									startMonth,
									startDay
								) />
			<cfset dEndDate = createDate(
									endYear,
									endMonth,
									endDay
								) />
	        <cfset startDim = objDates.setDim(
	        	{
	        		date = dStartDate,
	        		hour = arguments.occurrences[o1].startHour,
	        		minute = arguments.occurrences[o1].startMin
	        	}
	        ) />
	        <cfset endDim = objDates.setDim(
	        	{
	        		date = dEndDate,
	        		hour = arguments.occurrences[o1].endHour,
	        		minute = arguments.occurrences[o1].endMin
	        	}
	        ) />


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
			#listingID#,
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
		#listingID#,
		#internalPartnerID#,
		#arguments.category.ID#,
		NOW()
		)
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
				#listingID#,
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
								#listingID#,
								'#objTools.secureID()#',
								#internalRestrictionOptionID#
								)
							</cfquery>
						</cfif>
					</cfloop>
				</cfloop>
			</cfif>
		</cfloop>



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
						#listingID#,
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



		<cfif isDefined("arguments.kit")>
			<cfloop index="i1" list="#structKeyList(arguments.kit)#">
				<cfif arguments.kit[i1]['selected'] is true >
					<cfset internalKitID = objTools.internalID('kit',i1) />
					<cfquery datasource="startfly">
						INSERT INTO listingKit (
						listingID,
						kit
						) VALUES (
						#listingID#,
						#internalKitID#
						)
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>





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
			WHERE ID = #listingID#
			</cfquery>
		</cfif>



		<cfloop index="img1" from="1" to="#arrayLen(arguments.images)#">

	    	<cfquery datasource="startfly">
		    INSERT INTO listingImages (
		    listingID,
		    imageID,
		    created
		    ) VALUES (
		    #listingID#,
		    #arguments.images[img1].ID#,
		    NOW()
		    ) 
	    	</cfquery>
    	</cfloop>


		<cfset result['data']['listingID'] = listingSID />
		<cfset result['data']['status'] = 1 />
		<cfset result['data']['arguments'] = arguments />

		<cfset objTools.runtime('post', '/listing', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
