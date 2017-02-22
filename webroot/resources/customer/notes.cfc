<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/customer/{customerID}/notes" hint="some hint about this resource">
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
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfquery name="q" datasource="startfly">
		SELECT 
		customerNotes.*
		FROM customerNotes 
		WHERE customerNotes.customerID = #internalCustomerID# 
		AND customerNotes.partnerID = #internalPartnerID# 
		AND customerNotes.deleted = 0
		ORDER BY customerNotes.lastAmended DESC
		</cfquery>


			<cfset dataArray = arrayNew(1) />

			<cfloop query="q">
				<cfset dataArray[q.currentRow]['ID'] = q.sID />
				<cfset dataArray[q.currentRow]['customerID'] = arguments.customerID />
				<cfset dataArray[q.currentRow]['title'] = q.title />
				<cfset dataArray[q.currentRow]['content'] = q.content />
				<cfset dataArray[q.currentRow]['created'] = objDates.toJSON(q.created) />
				<cfset dataArray[q.currentRow]['lastAmended'] = objDates.toJSON(q.lastAmended) />
			</cfloop>

			<cfset result['data'] = dataArray />
			<cfset result['arguments'] = arguments />

		<cfset objTools.runtime('get', '/partner/{partnerID}/customer/{customerID}/notes', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>




	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset err = arrayNew(1) />

		<cfset okToPost = 1 />

		<cfif arguments.content is ''>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Please add some content') />
		</cfif>

		<cfif okToPost is 1>

			<cfset sID = objTools.secureID() />

			<cfset result['data']['ID'] = sID />


			<cfquery datasource="startfly">
			INSERT INTO customerNotes (
			sID,
			customerID,
			partnerID,
			title,
			content,
			created,
			lastAmended
			) VALUES (
			'#sID#',
			#internalCustomerID#,
			#internalPartnerID#,
			'#arguments.title#',
			'#arguments.content#',
			NOW(),
			NOW()
			)
			</cfquery>

			<cfset result['arguments'] = arguments />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'An error occurred' />
			<cfset result['errors'] = err />			
		</cfif>

		<cfset objTools.runtime('post', '/partner/{partnerID}/customer/{customerID}/notes', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="patch" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalnoteID = objTools.internalID('customerNotes',arguments.ID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset err = arrayNew(1) />

		<cfset okToPost = 1 />

		<cfif arguments.content is ''>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Please add some content') />
		</cfif>

		<cfif okToPost is 1>


 			<cfquery datasource="startfly">
			UPDATE customerNotes SET 
			title = '#arguments.title#',
			content = '#arguments.content#',
			lastAmended = NOW()
			WHERE sID = '#arguments.ID#'
			</cfquery>

			<cfset result['arguments'] = arguments />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'An error occurred' />
			<cfset result['errors'] = err />			
		</cfif>

		<cfset objTools.runtime('patch', '/partner/{partnerID}/customer/{customerID}/notes', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>