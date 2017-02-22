<cfcomponent extends="taffy.core.resource" taffy:uri="/booking/create" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset result['data']['result'] = 'charged' />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset arguments.listing.name = '' />
		<cfquery datasource="startfly">
		INSERT INTO bookingObjects(customerID,data) VALUES (#internalCustomerID#, '#SerializeJSON(arguments)#')
		</cfquery>

		<cfset rootDay = objTools.rootDay(now()) />

		<cfset net = numberFormat((arguments.charge.listingTotal / 1.2),'.00') />
		<cfset vat = arguments.charge.listingTotal - net />

		<cfif arguments.paymentPlan.selected is 0>
			<cfset paymentPlanID = 0 />
			<cfset totalPayments = 1 />
		<cfelse>
			<cfset secureIDPrefix = objAccum.newID('secureIDPrefix') />
			<cfset paymentPlanID = objAccum.newID('secureIDPrefix') />
			<cfset totalPayments = arrayLen(arguments.listing.occurrences) />
		</cfif>

		<cfset bookingID = objAccum.newID('secureIDPrefix') />
		<cfset secureBookingID = objTools.secureID() />


		<cfquery datasource="startfly">
		INSERT INTO bookings (
		ID,
		sID,
		partnerID,
		customerID,
		listingID,
		totalPaid,
		gross,
		vat,
		net,
		commission,
		paymentPlan,
		totalPayments,
		created,
		rootDay
		) VALUES (
		#bookingID#,
		'#secureBookingID#',
		#internalPartnerID#,
		#internalCustomerID#,
		#internalListingID#,
		#arguments.charge.toCharge#,
		#arguments.charge.listingTotal#,
		#vat#,
		#net#,
		0,
		#paymentPlanID#,
		#totalPayments#,
		NOW(),
		#rootDay#
		)
		</cfquery>

		<cfif arguments.listing.occurrenceType neq 8>


			<cfloop index="i1" from="1" to="#arrayLen(arguments.listing.occurrences)#">
				
				<cfif arguments.listing.occurrences[i1].selected is 1>
					<cfset detID = objAccum.newID('secureIDPrefix') />

					<cfset internalOccurrenceID = objTools.internalID('listingOccurrence',arguments.listing.occurrences[i1].ID) />

					<cfquery datasource="startfly">
					INSERT INTO bookingDetail (
					ID,
					sID,
					lineNo,
					bookingID,
					partnerID,
					customerID,
					listingID,
					occurrenceID,
					qty,
					created,
					rootDay
					) VALUES (
					#detID#,
					'#objTools.secureID()#',
					#i1#,
					#bookingID#,
					#internalPartnerID#,
					#internalCustomerID#,
					#internalListingID#,
					#internalOccurrenceID#,
					#arguments.qty#,
					NOW(),
					#rootDay#
					)
					</cfquery>

					<cfquery datasource="startfly">
					UPDATE bookingDetail, listingOccurrence SET 
					bookingDetail.startDateID = listingOccurrence.startDateID,
					bookingDetail.startTimeID = listingOccurrence.startTimeID,
					bookingDetail.endDateID = listingOccurrence.endDateID,
					bookingDetail.endTimeID = listingOccurrence.endTimeID 
					WHERE bookingDetail.occurrenceID = listingOccurrence.ID 
					AND bookingDetail.ID = #detID#
					</cfquery>

					<cfif arguments.listing.occurrences[i1].guestsSelected gt 0>
						<cfloop index="g1" from="1" to="#arguments.listing.occurrences[i1].guestsSelected#">
							<cfquery datasource="startfly">
							INSERT INTO bookingDetailAttendees (
							bookingDetailID,
							listingID,
							customerID,
							guestName
							) VALUES (
							#detID#,
							#internalListingID#,
							0,
							'Guest #g1#'
							)
							</cfquery>							
						</cfloop>						
					</cfif>

					<cfif arrayLen(arguments.listing.occurrences[i1].attending) gt 0>
						<cfloop index="i2" from="1" to="#arrayLen(arguments.listing.occurrences[i1].attending)#">
								<cfif arguments.listing.occurrences[i1].attending[i2].selected is 1>

									<cfset attendeeID = objTools.internalID('customer',arguments.listing.occurrences[i1].attending[i2].ID) />

									<cfquery datasource="startfly">
									INSERT INTO bookingDetailAttendees (
									bookingDetailID,
									listingID,
									customerID
									) VALUES (
									#detID#,
									#internalListingID#,
									#attendeeID#
									)
									</cfquery>							

									<cfquery name="customerCheck" datasource="startfly">
									SELECT ID 
									FROM partnerCustomers 
									WHERE partnerID = #internalPartnerID# 
									AND customerID = #attendeeID# 			
									</cfquery>

									<cfif customerCheck.recordCount is 0>

										<cfset dim = objDates.setDim({dateTime=now()}) />

										<cfquery datasource="startfly">
										INSERT INTO partnerCustomers (
										customerID,
										partnerID,
										listingID,
										dateID,
										timeID
										) VALUES (
										#attendeeID#,
										#internalPartnerID#,
										#internalListingID#,
										#dim.dateID#,
										#dim.timeID#
										)
										</cfquery>
									</cfif>

								</cfif> 
						</cfloop>
					</cfif>


				</cfif>

			</cfloop>
		<cfelse>
				<cfset detID = objAccum.newID('secureIDPrefix') />

				<cfset sessionDate = objTools.cfDateFromJSON(arguments.date,'-',0) />

				<cfquery name="dimDate" datasource="startfly">
				SELECT dateID 
				FROM dimDate 
				WHERE date = #sessionDate#
				</cfquery>

				<cfquery name="dimTime" datasource="startfly">
				SELECT timeID 
				FROM dimTime 
				WHERE theHour = #arguments.timeHour# 
				AND theMinute = #arguments.timeMinute#
				</cfquery>

				<cfquery datasource="startfly">
				INSERT INTO bookingDetail (
				ID,
				sID,
				lineNo,
				bookingID,
				partnerID,
				customerID,
				listingID,
				occurrenceID,
				qty,
				created,
				rootDay,
				sessionDate,
				sessionHour,
				sessionMin,
				duration,
				startDateID,
				startTimeID,
				endDateID,
				endTimeID
				) VALUES (
				#detID#,
				'#objTools.secureID()#',
				1,
				#bookingID#,
				#internalPartnerID#,
				#internalCustomerID#,
				#internalListingID#,
				0,
				#arguments.qty#,
				NOW(),
				#rootDay#,
				#objDates.toEpoch(sessionDate,'','-')#,
				#arguments.timeHour#,
				#arguments.timeMinute#,
				#arguments.duration#,
				#dimDate.dateID#,
				#dimTime.timeID#,
				#dimDate.dateID#,
				#(dimTime.timeID + arguments.duration)#
				)
				</cfquery>



				<cfloop index="i1" from="1" to="#arrayLen(arguments.listing.occurrences)#">

					<cfif arguments.listing.occurrences[i1].guestsSelected gt 0>
						<cfloop index="g1" from="1" to="#arguments.listing.occurrences[i1].guestsSelected#">
							<cfquery datasource="startfly">
							INSERT INTO bookingDetailAttendees (
							bookingDetailID,
							listingID,
							customerID,
							guestName
							) VALUES (
							#detID#,
							#internalListingID#,
							0,
							'Guest #g1#'
							)
							</cfquery>							
						</cfloop>						
					</cfif>


					<cfif arrayLen(arguments.listing.occurrences[i1].attending) gt 0>
						<cfloop index="i2" from="1" to="#arrayLen(arguments.listing.occurrences[i1].attending)#">
								<cfif arguments.listing.occurrences[i1].attending[i2].selected is 1>

									<cfset attendeeID = objTools.internalID('customer',arguments.listing.occurrences[i1].attending[i2].ID) />

									<cfquery datasource="startfly">
									INSERT INTO bookingDetailAttendees (
									bookingDetailID,
									listingID,
									customerID
									) VALUES (
									#detID#,
									#internalListingID#,
									#attendeeID#
									)
									</cfquery>							

									<cfquery name="customerCheck" datasource="startfly">
									SELECT ID 
									FROM partnerCustomers 
									WHERE partnerID = #internalPartnerID# 
									AND customerID = #attendeeID# 			
									</cfquery>

									<cfif customerCheck.recordCount is 0>

										<cfset dim = objDates.setDim({dateTime=now()}) />

										<cfquery datasource="startfly">
										INSERT INTO partnerCustomers (
										customerID,
										partnerID,
										listingID,
										dateID,
										timeID
										) VALUES (
										#attendeeID#,
										#internalPartnerID#,
										#internalListingID#,
										#dim.dateID#,
										#dim.timeID#
										)
										</cfquery>
									</cfif>


								</cfif> 
						</cfloop>
					</cfif>
				</cfloop>



		</cfif>


		<cfif isDefined("arguments.paymentPlan.payments")>
			<cfloop index="i1" from="1" to="#arrayLen(arguments.paymentPlan.payments)#">

				<cfset installmentID = objAccum.newID('secureIDPrefix') />

				<cfif i1 is 1>
					<cfset installmentPaid = 1 />
				<cfelse>
					<cfset installmentPaid = 0 />
				</cfif>



				<cfset cfPaymentDate = objTools.cfDateFromJSON(arguments.paymentPlan.payments[i1].paymentDate) />

				<cfset rootPaymentDay = objTools.rootDay(cfPaymentDate) />


				<cfquery datasource="startfly">
				INSERT INTO paymentPlan (
				ID,
				sID,
				paymentPlanID,
				bookingID,
				partnerID,
				customerID,
				listingID,
				paymentDate,
				rootPaymentDay,
				installment,
				amount,
				paid,
				created,
				rootDay
				) VALUES (
				#installmentID#,
				'#objTools.secureID()#',
				#paymentPlanID#,
				#bookingID#,
				#internalPartnerID#,
				#internalCustomerID#,
				#internalListingID#,
				#cfPaymentDate#,
				#rootPaymentDay#,
				#i1#,
				#arguments.paymentPlan.payments[i1].amount#,
				#installmentPaid#,
				NOW(),
				#rootDay#
				)
				</cfquery>

			</cfloop>
		</cfif>


		<!--- allocate this customer to the partner --->


		<cfquery name="customerCheck" datasource="startfly">
		SELECT ID 
		FROM partnerCustomers 
		WHERE partnerID = #internalPartnerID# 
		AND customerID = #internalCustomerID# 			
		</cfquery>

		<cfif customerCheck.recordCount is 0>

			<cfset dim = objDates.setDim({dateTime=now()}) />

			<cfquery datasource="startfly">
			INSERT INTO partnerCustomers (
			customerID,
			partnerID,
			listingID,
			dateID,
			timeID
			) VALUES (
			#internalCustomerID#,
			#internalPartnerID#,
			#internalListingID#,
			#dim.dateID#,
			#dim.timeID#
			)
			</cfquery>
		</cfif>


		<cfset objTools.runtime('post', '/booking/create', (getTickCount() - sTime) ) />

		<cfset result['data']['ID'] = bookingID />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
