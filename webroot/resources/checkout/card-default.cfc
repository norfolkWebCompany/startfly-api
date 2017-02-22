<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/card/{cardID}/default" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE cards SET isDefault = 0
		WHERE ownerID = #internalCustomerID#
		</cfquery>

		<cfquery datasource="startfly">
		UPDATE cards SET isDefault = 1
		WHERE sID = '#arguments.cardID#'
		</cfquery>


		<cfset objTools.runtime('get', '/customer/{customerID}/card/{cardID}/default', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
