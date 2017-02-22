<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/cards/{cardID}/charge" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset result['data']['result'] = 'charged' />


		<cfset objAccum = createObject('component','/resources/private/accum') />
		<cfset objStripe = createObject('component','/resources/stripe/stripe') />

		<cfset newID = objAccum.newID('secureIDPrefix') />

		<cfset rootDay = objTools.rootDay(now()) />

		<cfset result['data']['ID'] = newID />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalCardID = objTools.internalID('cards',arguments.card.ID) />

		<cfswitch expression="#arguments.checkoutModel#">
			<cfcase value="membership">
				<cfset internalMembershipID = objTools.internalID('memberships',arguments.membershipID) />
				<cfset internalListingID = 0 />
			</cfcase>
			<cfdefaultcase>
				<cfset internalMembershipID = 0 />
				<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />
			</cfdefaultcase>
		</cfswitch>

		<cfquery name="thisCustomer" datasource="startfly">
		SELECT stripeID 
		FROM customer 
		WHERE ID = #internalCustomerID#
		</cfquery>

		<cfquery name="thisCard" datasource="startfly">
		SELECT stripeID 
		FROM cards 
		WHERE ID = #internalCardID#
		</cfquery>

		<cfset stripeCharge = {
			amount = replace(numberFormat(arguments.charge.toCharge,'.__'),'.','','ALL'),
			currency = 'GBP',
			customerID = thisCustomer.stripeID,
			cardID = thisCard.stripeID,
			description = 'Coachee Ltd'
		} />

		<cfset chargeResult = objStripe.chargeCreate(stripeCharge) />

		<cfset result['data']['stripe'] = chargeResult />


		<cfif chargeResult.status is 1>

			<cfset result['data']['result'] = 'charged' />

			<cfquery datasource="startfly">
			INSERT INTO paymentsIn (
			ID,
			sID,
			partnerID,
			listingID,
			membershipID,
			customerID,
			checkoutModel,
			cardID,
			amount,
			created,
			rootDay,
			stripeID
			) VALUES (
			#newID#,
			'#objTools.secureID()#',
			#internalPartnerID#,
			#internalListingID#,
			#internalMembershipID#,
			#internalCustomerID#,
			'#arguments.checkoutModel#',
			#internalCardID#,
			#arguments.charge.toCharge#,
			NOW(),
			#rootDay#,
			'#chargeResult.chargeID#'
			)
			</cfquery>
		<cfelse>

			<cfset result['data']['result'] = 'declined' />
		</cfif>



			<cfset objTools.runtime('post', '/customer/{customerID}/cards/{cardID}/charge', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
