<cfcomponent extends="taffy.core.resource" taffy:uri="/public/listings/maxcost" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />


		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset sDate = objDates.setDim({date=now()}) />

		<cfquery name="occurrences" datasource="startfly" result="oc">
		SELECT 
		listingOccurrence.listingID 
		FROM listingOccurrence 
		WHERE startDateID > #sDate.dateID# 
		GROUP BY listingID
		</cfquery>

		<cfset result['qOccurrences'] = oc />

		<cfquery name="listings" datasource="startfly">
		SELECT 
		listing.cost
		FROM listing 
		WHERE listing.status = 1 
		AND listing.deleted = 0
        AND (
        	listing.ID IN (#valueList(occurrences.listingID)#) 
        	OR 
        	listing.workingHours > 0
        	)
        ORDER BY listing.cost DESC 
        LIMIT 1
		</cfquery>


		<cfset result['data']['maxCost'] = listings.cost />

		<cfset objTools.runtime('get', '/public/listings/maxcost', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
