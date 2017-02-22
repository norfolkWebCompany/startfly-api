<cfcomponent extends="taffy.core.resource" taffy:uri="/chat/new/" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="subject" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="userID" type="string" required="true" />
		<cfargument name="recipients" type="array" required="true" />


			<cfset objTools = createObject('component','/resources/private/tools') />
	        <cfset objDates = createObject('component','/resources/private/dates') />
			<cfset sTime = getTickCount() />

			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset dataArray = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />
			<cfset result['arguments'] = arguments />

			<cfset objEmail = createObject('component','/resources/private/email') />


			<cfset internalUserID = objTools.internalID('customer',arguments.userID) />

			<cfif internalUserID is 0>
				<cfset internalUserID = objTools.internalID('partner',arguments.userID) />
			</cfif>


	        <cfset chatID = objTools.secureID() />

	        <cfquery datasource="startfly" result="chat">
	        INSERT INTO chat (
	        sID,
	        subject,
	        owner,
	        created,
	        lastAction
	        ) VALUES (
	        '#chatID#',
	        '#arguments.subject#',
	        #internalUserID#,
	        NOW(),
	        NOW()
	        )
	        </cfquery>

			<cfloop index="i1" from="1" to="#arrayLen(arguments.recipients)#">
				
				<cfset internalSubscriberID = objTools.internalID('customer',arguments.recipients[i1]) />

				<cfif internalSubscriberID is 0>
					<cfset internalSubscriberID = objTools.internalID('partner',arguments.recipients[i1]) />
				</cfif>

				<cfquery datasource="startfly">
				INSERT INTO chatSubscriber (
					chatID,
					userID
				) VALUES (
					#chat.generatedKey#,
					#internalSubscriberID#
				)
				</cfquery>

			</cfloop>

	        <cfset chatContentID = objTools.secureID() />

	        <cfquery datasource="startfly">
	        INSERT INTO chatContent (
	        sID,
	        chatID,
	        userID,
	        created,
	        message
	        ) VALUES (
	        '#chatContentID#',
			#chat.generatedKey#,
	        #internalUserID#,
	        NOW(),
	        '#arguments.message#'
	        )
	        </cfquery>


			<cfset result['arguments'] = arguments />

			<cfset objTools.runtime('post', '/chat/new/', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
