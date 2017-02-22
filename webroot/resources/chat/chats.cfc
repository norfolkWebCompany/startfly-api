<cfcomponent extends="taffy.core.resource" taffy:uri="/chats/" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="userID" type="string" required="true" />


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


			<cfquery name="q" datasource="startfly">
			SELECT 
			chat.subject,
			chat.sID,
			chat.created,
			chat.lastAction,
			chat.owner,
			customer.avatar as customerAvatar,
			partner.avatar as partnerAvatar  
			FROM chatSubscriber 
			INNER JOIN chat ON chatSubscriber.chatID = chat.ID 
			LEFT JOIN customer ON chat.owner = customer.ID
			LEFT JOIN partner ON chat.owner = partner.ID
			WHERE chatSubscriber.userID = #internalUserID# 
			ORDER BY chat.lastAction DESC 
			</cfquery>

			<cfset dataArray = arrayNew(1) />
			<cfloop query="q">
				<cfset dataArray[q.currentRow]['ID'] = q.sID />
				<cfset dataArray[q.currentRow]['newMessages'] = 0 />
				<cfset dataArray[q.currentRow]['subject'] = q.subject />
				<cfset dataArray[q.currentRow]['created'] = dateFormat(q.created, "yyyy-mm-dd") & 'T' & timeFormat(q.created,"HH:mm:ss") & 'Z' />
				<cfset dataArray[q.currentRow]['lastAction'] = dateFormat(q.lastAction, "yyyy-mm-dd") & 'T' & timeFormat(q.lastAction,"HH:mm:ss") & 'Z' />
				<cfset dataArray[q.currentRow]['owner'] = q.owner />
				<cfif q.customerAvatar neq ''>
					<cfset dataArray[q.currentRow]['avatar'] = q.customerAvatar />
				</cfif>
				<cfif q.partnerAvatar neq ''>
					<cfset dataArray[q.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/partner/' & q.partnerAvatar />
				</cfif>
			</cfloop>

			<cfset result['data'] = dataArray />

			<cfset result['arguments'] = arguments />

			<cfset objTools.runtime('post', '/chats/', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
