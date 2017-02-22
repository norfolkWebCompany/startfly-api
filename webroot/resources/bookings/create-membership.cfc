<cfcomponent extends="taffy.core.resource" taffy:uri="/booking/create/membership" hint="some hint about this resource">

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
		<cfset internalMembershipID = objTools.internalID('memberships',arguments.membershipID) />
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />



		<cfset arguments.membership.name = '' />
		<cfquery datasource="startfly">
		INSERT INTO bookingObjects(customerID,data) VALUES (#internalCustomerID#, '#SerializeJSON(arguments)#')
		</cfquery>

		<cfset rootDay = objTools.rootDay(now()) />

		<cfset net = numberFormat((arguments.membership.cost / 1.2),'.00') />
		<cfset vat = arguments.membership.cost - net />


		<cfif arguments.paymentPlan.selected is 0>
			<cfset paymentPlanID = 0 />
			<cfset totalPayments = 1 />
		<cfelse>
			<cfset paymentPlanID = objAccum.newID('secureIDPrefix') />
			<cfset totalPayments = arrayLen(arguments.paymentPlan.payments) />
		</cfif>

		<cfset dimCreated = objDates.setDim({dateTime=now()}) />

		<cfquery name="dimStarts" datasource="startfly">
		SELECT dateID 
		FROM dimDate 
		WHERE monthDay = #arguments.contract.startDay# 
		AND monthNumber = #arguments.contract.startMonth# 
		AND year = #arguments.contract.startYear#
		</cfquery>


		<cfset bookingID = objAccum.newID('secureIDPrefix') />
		<cfset secureBookingID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO MembershipBooking (
		ID,
		sID,
		partnerID,
		customerID,
		membershipID,
		totalPaid,
		gross,
		vat,
		net,
		commission,
		paymentPlan,
		totalPayments,
		created,
		dateIDCreated,
		startDate
		) VALUES (
		#bookingID#,
		'#secureBookingID#',
		#internalPartnerID#,
		#internalCustomerID#,
		#internalMembershipID#,
		#arguments.charge.toCharge#,
		#arguments.charge.membershipTotal#,
		#vat#,
		#net#,
		0,
		#paymentPlanID#,
		#totalPayments#,
		NOW(),
		#dimCreated.dateID#,
		#dimStarts.dateID#
		)
		</cfquery>


		<cfif arrayLen(arguments.attending) gt 0>
			<cfloop index="i1" from="1" to="#arrayLen(arguments.attending)#">
				<cfif arguments.attending[i1].selected is 1>

					<cfset attendeeID = objTools.internalID('customer',arguments.attending[i1].ID) />

					<cfquery datasource="startfly">
					INSERT INTO membershipMembers (
					membershipID,
					customerID
					) VALUES (
					#internalMembershipID#,
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
						membershipID,
						dateID,
						timeID
						) VALUES (
						#attendeeID#,
						#internalPartnerID#,
						#internalMembershipID#,
						#dim.dateID#,
						#dim.timeID#
						)
						</cfquery>
					</cfif>



				</cfif> 
			</cfloop>
		</cfif>





		<cfif isDefined("arguments.paymentPlan.payments")>
			<cfloop index="i1" from="1" to="#arrayLen(arguments.paymentPlan.payments)#">

				<cfset installmentID = objAccum.newID('secureIDPrefix') />

				<cfif i1 is 1 and arguments.charge.toCharge gt 0>
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
				membershipID,
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
				#internalMembershipID#,
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


		<cfset objTools.runtime('post', '/booking/create/membership', (getTickCount() - sTime) ) />

		<cfset result['data']['ID'] = bookingID />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
