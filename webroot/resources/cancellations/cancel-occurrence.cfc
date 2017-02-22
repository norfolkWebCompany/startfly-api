<cfcomponent extends="taffy.core.resource" taffy:uri="/cancel/occurrence" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="false" default="" />
		<cfargument name="occurrenceID" type="string" required="false" default="" />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

        <cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
        <cfset internalOccurrenceID = objTools.internalID('listingOccurrence',arguments.occurrenceID) />

        <cfquery datasource="startfly">
	    UPDATE listingOccurrence SET 
	    cancelled = 1,
	    cancellationReason = #arguments.reason#,
	    cancellationReasonText = '#arguments.message#',
	    cancellationDate = NOW(),
	    cancelledBy = 'Partner'
	    WHERE ID = #internalOccurrenceID#
        </cfquery>

        <cfquery datasource="startfly">
	    UPDATE bookingDetail SET 
	    status = 4,
	    cancellationReason = #arguments.reason#,
	    cancellationReasonText = '#arguments.message#',
	    cancellationDate = NOW(),
	    cancelledBy = 'Partner'
	    WHERE occurrenceID = #internalOccurrenceID#
        </cfquery>


			<cfset objTools.runtime('post', '/cancel/occurrence', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
