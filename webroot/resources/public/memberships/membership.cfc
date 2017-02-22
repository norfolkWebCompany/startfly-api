<cfcomponent extends="taffy.core.resource" taffy:uri="/public/membership/{membershipID}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset sTime = getTickCount() />

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
		paymentFrequency.ID AS paymentFrequencyID,
		paymentFrequency.name AS paymentFrequencyName,
		paymentFrequency.descriptiveName AS paymentFrequencyDescriptive,
		emailResponse.SID as responseSID,
		restrictionGenre.sID AS genreSID,
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
		partner.youtubeURL
		FROM memberships 
		INNER JOIN membershipTypes ON memberships.type = membershipTypes.ID 
		LEFT JOIN emailResponse ON memberships.responseID = emailResponse.ID 
		LEFT JOIN restrictionGenre ON memberships.genre = restrictionGenre.ID 
		LEFT JOIN partner ON memberships.partnerID = partner.ID 
		INNER JOIN paymentFrequency ON memberships.paymentFrequency = paymentFrequency.ID
		WHERE memberships.status = 1 
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
			<cfset result['data']['responseID'] = memberships.responseSID />
			<cfset result['data']['cost'] = memberships.price />

			<cfset result['data']['pricingModel']['ID'] = memberships.pricingModel />
			<cfif memberships.pricingModel is 1>
				<cfset result['data']['pricingModel']['description'] = 'per sign up' />
			<cfelse>
				<cfset result['data']['pricingModel']['description'] = 'per person' />
			</cfif>

			<cfset result['data']['spaces'] = memberships.memberLimit />
			<cfset result['data']['restrictionGenre'] = memberships.genreSID />
			<cfset result['data']['isGroup'] = memberships.isGroup />
			<cfset result['data']['groupMin'] = memberships.groupMin />
			<cfset result['data']['groupMax'] = memberships.groupMax />
			<cfset result['data']['terms'] = memberships.terms />
			<cfset result['data']['startType']['type'] = memberships.start />
			<cfset result['data']['startType']['proRataType'] = memberships.startProRata />
			<cfset result['data']['startType']['startDate'] = objDates.getDim(memberships.startDate,1,'JSON') />


			<cfset result['data']['autoRenew'] = memberships.autoRenew />

			<cfset result['data']['dayOfMonth'] = memberships.dayOfMonth />

			<cfset contractStartDate = objDates.getDim(memberships.startDate,0,'') />

			<cfset result['data']['contract']['type'] = memberships.type />
			<cfset result['data']['contract']['startType'] = memberships.start />
			<cfset result['data']['contract']['length'] = memberships.minContract />
			<cfset result['data']['contract']['minContract'] = memberships.minContract />
			<cfset result['data']['contract']['name'] = memberships.typeName />
			<cfset result['data']['contract']['allowCancellation'] = memberships.allowCancellation />


			<cfset nextDate = dateAdd('m',1,now()) />
			<cfswitch expression="#memberships.start#">
				<cfcase value="1">
					<cfset result['data']['contract']['startDay'] = day(now()) />
					<cfset result['data']['contract']['startMonth'] = month(now()) />
					<cfset result['data']['contract']['startYear'] = year(now()) />
				</cfcase>
				<cfcase value="2">
					<cfif memberships.startProRata is 1>
						<cfset result['data']['contract']['startDay'] = day(now()) />
						<cfset result['data']['contract']['startMonth'] = month(now()) />
						<cfset result['data']['contract']['startYear'] = year(now()) />
					<cfelse>
						<cfset result['data']['contract']['startDay'] = memberships.dayOfMonth />
						<cfset result['data']['contract']['startMonth'] = month(nextDate) />
						<cfset result['data']['contract']['startYear'] = year(nextDate) />
					</cfif>
				</cfcase>
				<cfcase value="3">
					<cfset result['data']['contract']['startDay'] = day(contractStartDate) />
					<cfset result['data']['contract']['startMonth'] = month(contractStartDate) />
					<cfset result['data']['contract']['startYear'] = year(contractStartDate) />
				</cfcase>
				<cfcase value="4">
					<cfset result['data']['contract']['startDay'] = memberships.dayOfMonth />
					<cfset result['data']['contract']['startMonth'] = month(nextDate) />
					<cfset result['data']['contract']['startYear'] = year(nextDate) />
				</cfcase>
			</cfswitch>

			<cfset result['data']['paymentPlan']['ID'] = memberships.paymentFrequencyID />
			<cfset result['data']['paymentPlan']['allowed'] = memberships.allowPaymentPlan />
			<cfset result['data']['paymentPlan']['paymentFrequencyID'] = memberships.paymentFrequency />
			<cfset result['data']['paymentPlan']['paymentFrequency'] = memberships.paymentFrequencyName />
			<cfset result['data']['paymentPlan']['paymentsTotal'] = memberships.paymentPlanPayments />
			<cfset result['data']['paymentPlan']['descriptive'] = memberships.paymentFrequencyDescriptive />
			<cfif memberships.allowPaymentPlan is 1>
				<cfset result['data']['paymentPlan']['selected'] = 1 />
			<cfelse>
				<cfset result['data']['paymentPlan']['selected'] = 0 />
			</cfif>

			<cfset result['data']['partner']['partnerID'] = memberships.partnerSID />
			<cfset result['data']['partner']['created'] = objDates.fromEpoch(memberships.partnerCreated,'JSON') />
			<cfif memberships.useBusinessName is 0>
				<cfset result['data']['partner']['name'] = memberships.firstname & ' ' & memberships.surname />
				<cfset result['data']['partner']['firstname'] = memberships.firstname />
			<cfelse>
				<cfset result['data']['partner']['name'] = memberships.company />
				<cfset result['data']['partner']['firstname'] = memberships.company />
			</cfif>
			<cfset result['data']['partner']['nickname'] = memberships.nickname />
			<cfset result['data']['partner']['preview'] = memberships.partnerPreview />
			<cfset result['data']['partner']['gender'] = memberships.gender />
			<cfset result['data']['partner']['imageURL'] = 'https://beta.startfly.co.uk/images/partner/' & memberships.avatar />

			<cfif 
				memberships.webURL neq '' OR 
				memberships.fbURL neq '' OR 
				memberships.twitterURL neq '' OR 
				memberships.youtubeURL neq '' OR 
				memberships.instagramURL neq ''>
					
				<cfset result['data']['partner']['hasSocial'] = 1 />
			<cfelse>
				<cfset result['data']['partner']['hasSocial'] = 0 />
			</cfif>

			<cfset result['data']['partner']['webURL'] = memberships.webURL />
			<cfset result['data']['partner']['fbURL'] = memberships.fbURL />
			<cfset result['data']['partner']['twitterURL'] = memberships.twitterURL />
			<cfset result['data']['partner']['instagramURL'] = memberships.instagramURL />
			<cfset result['data']['partner']['youtubeURL'] = memberships.youtubeURL />


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





<!--- 			<cfquery name="restrictions" datasource="startfly">
			SELECT 
			listingRestrictions.optionID,
			restrictionOption.name
			FROM listingRestrictions 
			INNER JOIN restrictionOption ON listingRestrictions.optionID = restrictionOption.ID 
			WHERE listingRestrictions.listingID = #memberships.membershipID# 
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
 --->


		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/public/membership/{membershipID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
