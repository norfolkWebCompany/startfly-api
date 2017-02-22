<cfcomponent extends="taffy.core.resource" taffy:uri="/chat/" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="chatID" type="string" required="true" />


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

			<cfquery name="q" datasource="startfly">
			SELECT 
			chat.subject,
			chat.sID,
			chat.created,
			chat.lastAction,
			chat.owner  
			FROM chat 
			WHERE chat.ID = #internalChatID# 
			</cfquery>


			<cfset result['data']['ID'] = q.sID />
			<cfset result['data']['newMessages'] = 0 />
			<cfset result['data']['subject'] = q.subject />
			<cfset result['data']['created'] = dateFormat(q.created, "yyyy-mm-dd") & 'T' & timeFormat(q.created,"HH:mm:ss") & 'Z' />
			<cfset result['data']['lastAction'] = dateFormat(q.lastAction, "yyyy-mm-dd") & 'T' & timeFormat(q.lastAction,"HH:mm:ss") & 'Z' />
			<cfset result['data']['owner'] = q.owner />

			<cfquery name="content" datasource="startfly">
			SELECT 
			chatContent.sID,
			chatContent.message,
			chatContent.created,
			CONCAT(customer.firstName,' ',customer.surname) AS customerName, 
			CONCAT(partner.firstName,' ',partner.surname) AS partnerName,
			customer.sID as customerSID,
			partner.sID as partnerSID
			FROM chatContent 
			LEFT JOIN customer ON chatContent.userID = customer.ID
			LEFT JOIN partner ON chatContent.userID = partner.ID
			WHERE chatContent.chatID = #internalChatID# 
			ORDER BY chatContent.ID DESC
			</cfquery>

			<cfset dataArray = arrayNew(1) />

			<cfloop query="content">
				<cfset dataArray[content.currentRow]['ID'] = content.sID />
				<cfset dataArray[content.currentRow]['message'] = content.message />
				<cfset dataArray[content.currentRow]['created'] = dateFormat(content.created, "yyyy-mm-dd") & 'T' & timeFormat(content.created,"HH:mm:ss") & 'Z' />
				<cfif content.customerName neq ''>
					<cfset dataArray[content.currentRow]['name'] = content.customerName />
					<cfset dataArray[content.currentRow]['userID'] = content.customerSID />
				<cfelse>
					<cfset dataArray[content.currentRow]['name'] = content.partnerName />
					<cfset dataArray[content.currentRow]['userID'] = content.partnerSID />
				</cfif>
			</cfloop>

			<cfset result['data']['messages'] = dataArray />

			<cfset result['arguments'] = arguments />

			<cfset objTools.runtime('post', '/chat/', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
