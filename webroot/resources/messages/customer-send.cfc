<cfcomponent extends="taffy.core.resource" taffy:uri="/messages/customer/{customerID}/send/" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="recipients" type="array" required="true" />
		<cfargument name="customerID" type="string" required="true" />
		<cfargument name="uID" type="string" required="false" default="" />
		<cfargument name="subject" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />


			<cfset objTools = createObject('component','/resources/private/tools') />
			<cfset sTime = getTickCount() />

			<cfset objEmail = createObject('component','/resources/private/email') />

			<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

			<cfloop index="i1" from="1" to="#arrayLen(arguments.recipients)#">
				
				<cfset internalPartnerID = objTools.internalID('partner',arguments.recipients[i1]) />

				<cfset result = {} />
				<cfset result['status'] = {} />
				<cfset dataArray = {} />
				<cfset result['status']['statusCode'] = 200 />
				<cfset result['status']['message'] = 'OK' />
				<cfset result['arguments'] = arguments />

				<cfquery name="thisCustomer" datasource="startfly">
				SELECT email 
				FROM customer 
				WHERE ID = #internalCustomerID#
				</cfquery>

				<cfquery name="thisPartner" datasource="startfly">
				SELECT partner.email 
				FROM partner  
				WHERE partner.ID = #internalPartnerID# 
				</cfquery>

				<cfset messageData = {
					sentFrom = thisCustomer.email,
					sentTo = thisPartner.email,
					type = arguments.type,
					uID = arguments.uID,
					folder = 'Inbox',
					subject = arguments.subject,
					content = arguments.content
				} />

				<cfset result['data']['messageID'] = objEmail.send(messageData) />


			</cfloop>

			<cfset result['arguments'] = arguments />

			<cfset objTools.runtime('post', '/messages/customer/{customerID}/send/', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
