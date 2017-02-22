<cfcomponent extends="taffy.core.resource" taffy:uri="/messages/partner/{partnerID}/send/" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="recipients" type="array" required="true" />
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="occurrenceID" type="string" required="false" default="0" />
		<cfargument name="subject" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />


			<cfset objTools = createObject('component','/resources/private/tools') />
			<cfset sTime = getTickCount() />

			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset dataArray = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />
			<cfset result['arguments'] = arguments />

			<cfset objEmail = createObject('component','/resources/private/email') />

			<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

			<cfloop index="i1" from="1" to="#arrayLen(arguments.recipients)#">
				
					<cfset internalCustomerID = objTools.internalID('customer',arguments.recipients[i1]) />

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
						sentFrom = thisPartner.email,
						sentTo = thisCustomer.email,
						type = arguments.type,
						uID = arguments.occurrenceID,
						folder = 'Inbox',
						subject = arguments.subject,
						content = arguments.content
					} />

				<cfset result['data']['messageID'] = objEmail.send(messageData) />


			</cfloop>

			<cfset result['arguments'] = arguments />

			<cfset objTools.runtime('post', '/messages/partner/{partnerID}/send/', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
