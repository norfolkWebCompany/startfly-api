<cfcomponent extends="taffy.core.resource" taffy:uri="/chat/reply/" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="chatID" type="string" required="true" />
		<cfargument name="message" type="string" required="true" />
		<cfargument name="userID" type="string" required="true" />
		<cfargument name="source" type="string" required="true" />


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


			<cfset internalChatID = objTools.internalID('chat',arguments.chatID) />
			<cfset internalUserID = objTools.internalID('customer',arguments.userID) />

			<cfif internalUserID is 0>
				<cfset internalUserID = objTools.internalID('partner',arguments.userID) />
			</cfif>


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
			#internalChatID#,
	        #internalUserID#,
	        NOW(),
	        '#arguments.message#'
	        )
	        </cfquery>

	        <cfquery datasource="startfly">
	        UPDATE chat SET 
	        lastAction = NOW() 
	        WHERE ID = #internalChatID#
		    </cfquery>


			<cfset result['data']['ID'] = chatContentID />
			<cfset result['data']['message'] = arguments.message />
			<cfset result['data']['created'] = dateFormat(now(), "yyyy-mm-dd") & 'T' & timeFormat(now(),"HH:mm:ss") & 'Z' />
			<cfset result['data']['userID'] = arguments.userID />
			<cfset result['data']['name'] = arguments.name />



			<cfset result['arguments'] = arguments />

			<cfset objTools.runtime('post', '/chat/new/', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
