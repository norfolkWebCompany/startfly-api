<cfcomponent extends="taffy.core.resource" taffy:uri="/public/partner/{partnerID}/memberships" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" default="" />

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
		ORDER BY memberships.name
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfloop query="memberships">
			
			<cfset dataArray[memberships.currentRow]['membershipID'] = memberships.sID />
			<cfset dataArray[memberships.currentRow]['name'] = memberships.name />
			<cfset dataArray[memberships.currentRow]['type'] = memberships.type />
			<cfset dataArray[memberships.currentRow]['imageURL'] = memberships.imageURL />
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

		<cfset objTools.runtime('get', '/public/partner/{partnerID}/memberships', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>



</cfcomponent>
