<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/memberships/{membershipID}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalMembershipID = objTools.internalID('memberships',arguments.membershipID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="memberships" datasource="startfly">
		SELECT 
		memberships.*,
		membershipTypes.name AS typeName,
		emailResponse.SID as responseSID,
		restrictionGenre.sID AS genreSID,
		dimDate.date as dimStartDate  
		FROM memberships 
		INNER JOIN membershipTypes ON memberships.type = membershipTypes.ID 
		LEFT JOIN emailResponse ON memberships.responseID = emailResponse.ID 
		LEFT JOIN dimDate ON memberships.startDate = dimDate.dateID 
		LEFT JOIN restrictionGenre ON memberships.genre = restrictionGenre.ID 
		WHERE memberships.status = 1 
		AND memberships.partnerID = #internalPartnerID#
		AND memberships.ID = #internalMembershipID#
		</cfquery>


		<cfset data = structNew() />

		<cfif memberships.recordCount gt 0>
			
			<cfset result['data']['membershipID'] = memberships.sID />
			<cfset result['data']['name'] = memberships.name />
			<cfset result['data']['imageURL'] = memberships.imageURL />
			<cfset result['data']['description'] = memberships.description />
			<cfset result['data']['ageMin'] = memberships.ageMin />
			<cfset result['data']['ageMax'] = memberships.ageMax />
			<cfset result['data']['termsText'] = memberships.terms />
			<cfset result['data']['cancellationPolicy'] = memberships.cancellationPolicy />
			<cfset result['data']['responseID'] = memberships.responseSID />
			<cfset result['data']['cost'] = memberships.price />
			<cfset result['data']['pricingModel'] = memberships.pricingModel />
			<cfset result['data']['capacity'] = memberships.memberLimit />
			<cfset result['data']['restrictionGenre'] = memberships.genreSID />
			<cfset result['data']['isGroup'] = memberships.isGroup />
			<cfset result['data']['groupMin'] = memberships.groupMin />
			<cfset result['data']['groupMax'] = memberships.groupMax />

			<cfset result['data']['autoRenew'] = memberships.autoRenew />
			<cfset result['data']['start'] = memberships.start />
			<cfset result['data']['startProRata'] = memberships.startProRata />
			<cfset result['data']['startDate'] = objDates.getDim(memberships.startDate,1,'JSON') />
			<cfset result['data']['freeTrial'] = memberships.freeTrial />
			<cfset result['data']['freeTrialLength'] = memberships.freeTrialLength />
			<cfset result['data']['freeTrialPeriod'] = memberships.freeTrialPeriod />
			<cfset result['data']['minContract'] = memberships.minContract />
			<cfset result['data']['allowCancellation'] = memberships.allowCancellation />
			<cfset result['data']['allowPaymentPlan'] = memberships.allowPaymentPlan />
			<cfset result['data']['paymentFrequency'] = memberships.paymentFrequency />
			<cfset result['data']['paymentPlanPayments'] = memberships.paymentPlanPayments />
			<cfset result['data']['dayOfMonth'] = memberships.dayOfMonth />


			<cfset result['data']['type'] = memberships.type />
			<cfset result['data']['typeName'] = memberships.typeName />
			<cfset result['data']['status'] = memberships.status />
			<cfset result['data']['deleted'] = memberships.deleted />

			<cfquery name="memRestrictions" datasource="startfly">
			SELECT 
			membershipRestrictions.optionID,
			restrictionOption.sID 
			FROM membershipRestrictions 
			INNER JOIN restrictionOption ON membershipRestrictions.optionID = restrictionOption.ID 
			WHERE membershipRestrictions.membershipID = #internalMembershipID#
			</cfquery>

			<cfif memRestrictions.recordCount gt 0>
				<cfquery name="remainRestrictions" datasource="startfly">
				SELECT restrictionOption.SID 
				FROM restrictionOption 
				WHERE status = 1 
				AND Deleted = 0 
				AND ID NOT IN (#valueList(memRestrictions.optionID)#)
				</cfquery>
			<cfelse>
				<cfquery name="remainRestrictions" datasource="startfly">
				SELECT restrictionOption.SID 
				FROM restrictionOption 
				WHERE status = 1 
				AND Deleted = 0
				</cfquery>
			</cfif>

			<cfloop query="memRestrictions">
				<cfset result['data']['restrictions'][memRestrictions.sID]['selected'] = true />
			</cfloop>
			<cfloop query="remainRestrictions">
				<cfset result['data']['restrictions'][remainRestrictions.sID]['selected'] = false />
			</cfloop>


		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/partner/{partnerID}/memberships/{membershipID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="patch" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalMembershipID = objTools.internalID('memberships',arguments.membershipID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalGenreID = objTools.internalID('restrictionGenre',arguments.restrictionGenre) />
		<cfset internalResponseID = objTools.internalID('emailResponse',arguments.responseID) />
		<cfset internalGenreID = objTools.internalID('restrictionGenre',arguments.restrictionGenre) />

		<cfif arguments.startDate neq ''>
		<cfset cfDate = objTools.cfDateFromJSON(arguments.startDate,'-') />

			<cfif isDate(cfDate)>
				<cfset dateDim = objDates.setDim({date = cfDate}) />
				<cfset startDateID = dateDim.dateID />
			</cfif>
		</cfif>


		<cfquery datasource="startfly">
		UPDATE memberships SET 
		name = '#arguments.name#',
		description = '#arguments.description#', 
		type = #arguments.type#, 
		price = #arguments.cost#, 
		pricingModel = #arguments.pricingModel#,
		ageMax = #arguments.ageMax#,
		ageMin = #arguments.ageMin#,
		groupMin = #arguments.groupMin#,
		groupMax = #arguments.groupMax#,
		isGroup = #arguments.isGroup#,
		start = #arguments.start#,
		startDate = #startDateID#,
		startProRata = #arguments.startProRata#,
		terms = '#arguments.termsText#',
		cancellationPolicy = '#arguments.cancellationPolicy#',
		type = #arguments.type#,
		freeTrial = #arguments.freeTrial#,
		freeTrialLength = #arguments.freeTrialLength#,
		freeTrialPeriod = #arguments.freeTrialPeriod#,
		minContract = #arguments.minContract#,
		autoRenew = #arguments.autoRenew#,
		memberLimit = #arguments.capacity#,
		responseID = #internalResponseID#,
		genre = #internalGenreID#,
		status = #arguments.status#,
		deleted = #arguments.deleted#, 
		allowCancellation = #arguments.allowCancellation#,
		allowPaymentPlan = #arguments.allowPaymentPlan#,
		paymentFrequency = #arguments.paymentFrequency#,
		paymentPlanPayments = #arguments.paymentPlanPayments#,
		dayOfMonth = #arguments.dayOfMonth#
		WHERE sID = '#arguments.membershipID#' 
		AND partnerID = #internalPartnerID#
		</cfquery>

		<cfquery datasource="startfly">
		DELETE FROM membershipRestrictions 
		WHERE membershipID = #internalMembershipID#
		</cfquery>

		<cfloop index="i1" list="#structKeyList(arguments.restrictions)#">
			<cfif arguments.restrictions[i1].selected is true >
				<cfset internalRestrictionOptionID = objTools.internalID('restrictionOption',i1) />

				<cfquery datasource="startfly">
					INSERT INTO membershipRestrictions (
					membershipID,
					sID,
					optionID
					) VALUES (
					#internalMembershipID#,
					'#objTools.secureID()#',
					#internalRestrictionOptionID#
					)
				</cfquery>
			</cfif>
		</cfloop>



		<cfset result['arguments'] = arguments />

		<cfset objTools.runtime('patch', '/partner/{partnerID}/memberships/{membershipID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

	<cffunction name="delete" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="membershipID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE memberships 
		SET deleted = 1 
		WHERE sID = '#arguments.membershipID#'
		</cfquery>

		<cfset result['data']['membershipID'] = arguments.membershipID />

		<cfset objTools.runtime('delete', '/partner/{partnerID}/memberships/{membershipID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
