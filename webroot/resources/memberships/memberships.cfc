<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/memberships" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="type" type="numeric" required="false" default="0" />
		<cfargument name="status" type="numeric" required="false" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="memberships" datasource="startfly">
		SELECT 
		memberships.*,
		membershipTypes.name AS typeName
		FROM memberships 
		INNER JOIN membershipTypes ON memberships.type = membershipTypes.ID
		WHERE memberships.partnerID = #internalPartnerID# 
		AND memberships.deleted = 0 
		<cfif isDefined("arguments.status")>
			AND memberships.status = #arguments.status#
		</cfif>
		ORDER BY memberships.name
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfloop query="memberships">
			
			<cfset dataArray[memberships.currentRow]['membershipID'] = memberships.sID />
			<cfset dataArray[memberships.currentRow]['name'] = memberships.name />
			<cfset dataArray[memberships.currentRow]['type'] = memberships.type />
			<cfset dataArray[memberships.currentRow]['typeName'] = memberships.typeName />
			<cfset dataArray[memberships.currentRow]['description'] = memberships.description />
			<cfset dataArray[memberships.currentRow]['price'] = memberships.price />
			<cfset dataArray[memberships.currentRow]['freeTrial'] = memberships.freeTrial />
			<cfset dataArray[memberships.currentRow]['freeTrialLength'] = memberships.freeTrialLength />
			<cfset dataArray[memberships.currentRow]['freeTrialPeriod'] = memberships.freeTrialPeriod />
			<cfset dataArray[memberships.currentRow]['minContract'] = memberships.minContract />
			<cfset dataArray[memberships.currentRow]['autoRenew'] = memberships.autoRenew />
			<cfset dataArray[memberships.currentRow]['memberLimit'] = memberships.memberLimit />
			<cfset dataArray[memberships.currentRow]['status'] = memberships.status />
			<cfset dataArray[memberships.currentRow]['deleted'] = memberships.deleted />

		</cfloop>

		<cfset result['data'] = dataArray />

		<cfset objTools.runtime('get', '/partner/{partnerID}/memberships', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset objAccum = createObject('component','/resources/private/accum') />
		<cfset membershipID = objAccum.newID('secureIDPrefix') />
		<cfset sID = objTools.secureID() />


		<cfset internalResponseID = objTools.internalID('emailResponse',arguments.responseID) />
		<cfset internalGenreID = objTools.internalID('restrictionGenre',arguments.restrictionGenre) />

		<cfset startDateID = 0 />

		<cfif arguments.startDate neq ''>
		<cfset cfDate = objTools.cfDateFromJSON(arguments.startDate,'-') />

		<cfif isDate(cfDate)>
			<cfset dateDim = objDates.setDim({date = cfDate}) />
			<cfset startDateID = dateDim.dateID />
		</cfif>
		</cfif>

		<cfquery datasource="startfly">
		INSERT INTO memberships (
		ID,
		sID,
		partnerID,
		type,
		name,
		description,
		price,
		pricingModel,
		freeTrial,
		freeTrialLength,
		freeTrialPeriod,
		minContract,
		autoRenew,
		genre,
		memberLimit,
		ageMin,
		ageMax,
		isGroup,
		groupMin,
		groupMax,
		imageURL,
		responseID,
		terms,
		cancellationPolicy,
		status,
		start,
		startProRata,
		startDate,
		created,
		allowCancellation,
		allowPaymentPlan,
		paymentFrequency,
		paymentPlanPayments,
		dayOfMonth
		) VALUES (
		#membershipID#,
		'#sID#',
		#internalPartnerID#,
		#arguments.type#,
		'#arguments.name#',
		'#arguments.description#',
		#arguments.cost#,
		#arguments.pricingModel#,
		#arguments.freeTrial#,
		#arguments.freeTrialLength#,
		#arguments.freeTrialPeriod#,
		#arguments.minContract#,
		#arguments.autoRenew#,
		#internalGenreID#,
		#arguments.capacity#,
		#arguments.ageMin#,
		#arguments.ageMax#,
		#arguments.isGroup#,
		#arguments.groupMin#,
		#arguments.groupMax#,
		'#replace(arguments.imageURL,"membership/tmp/","membership/")#',
		#internalResponseID#,
		'#arguments.termsText#',
		'#arguments.cancellationPolicy#',
		1,
		#arguments.start#,
		#arguments.startProRata#,
		#startDateID#,
		NOW(),
		#arguments.allowCancellation#,
		#arguments.allowPaymentPlan#,
		#arguments.paymentFrequency#,
		#arguments.paymentPlanPayments#,
		#arguments.dayOfMonth#
		)
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
					#membershipID#,
					'#objTools.secureID()#',
					#internalRestrictionOptionID#
					)
				</cfquery>
			</cfif>
		</cfloop>


		<cfset fileDir = 'D:\domains\beta.startfly.co.uk\wwwroot\images\membership\'>
		<cfset fileName = listLast(arguments.imageURL,'/') />

		<cfset oldFileName = fileDir & 'tmp\' & fileName />
		<cfset newFileName = fileDir & fileName />

		<cfif fileExists(oldFileName)>
			<cffile  
			    action="move" 
			    destination = "#newFileName#"  
			    source = "#oldFileName#" />
    	</cfif>



		<cfquery name="memType" datasource="startfly">
		SELECT membershipTypes.name 
		FROM membershipTypes 
		WHERE ID = #arguments.type#
		</cfquery>

		<cfset result['data']['membership']['membershipID'] = sID />

		<cfset objTools.runtime('post', '/partner/{partnerID}/memberships', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
