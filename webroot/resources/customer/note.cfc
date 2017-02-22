<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/customer/{customerID}/note/{ID}" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">
		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfquery name="q" datasource="startfly">
		SELECT 
		customerNotes.*
		FROM customerNotes 
		WHERE customerNotes.sID = '#arguments.ID#'
		</cfquery>


			<cfset result['data']['ID'] = q.sID />
			<cfset result['data']['title'] = q.title />
			<cfset result['data']['content'] = q.content />
			<cfset result['data']['created'] = objDates.toJSON(q.created) />
			<cfset result['data']['lastAmended'] = objDates.toJSON(q.lastAmended) />

		<cfset objTools.runtime('get', '/partner/{partnerID}/customer/{customerID}/note/{ID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="delete" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE customerNotes SET 
		deleted = 1  
		WHERE sID = '#arguments.ID#'
		</cfquery>

		<cfset objTools.runtime('delete', '/partner/{partnerID}/{customerID}/customer/note/{ID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>