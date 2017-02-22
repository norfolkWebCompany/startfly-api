<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/email/preferences" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="q" datasource="startfly">
		SELECT 
		customer.promoEmails,
		customer.reminderEmails
		FROM customer 
		WHERE customer.ID = #internalCustomerID#
		</cfquery>


		<cfset result['data']['promoEmails'] = q.promoEmails />
		<cfset result['data']['reminderEmails'] = q.reminderEmails />


		<cfset objTools.runtime('post', '/customer/{customerID}/email/preferences', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>



	<cffunction name="post" access="public" output="false">

			<cfset objTools = createObject('component','/resources/private/tools') />
			<cfset sTime = getTickCount() />

			<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />


			<cfquery datasource="startfly">
			UPDATE customer SET 
			promoEmails = #arguments.promoEmails#,
			reminderEmails = #arguments.reminderEmails# 
			WHERE ID = #internalCustomerID#
			</cfquery>

			<cfset result['data']['args'] = arguments />


			<cfset objTools.runtime('post', '/customer/{customerID}/email/preferences', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
