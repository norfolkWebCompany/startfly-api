<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/response" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="type" type="numeric" required="false" default="0" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="emailResponse" datasource="startfly">
		SELECT 
		emailResponse.*
		FROM emailResponse 
		WHERE emailResponse.status = 1 
		<cfif arguments.type is 0>
		AND (partnerID = #internalPartnerID# or partnerID = 0)
		<cfelse>
		AND partnerID = #internalPartnerID#
		</cfif>
		AND deleted = 0
		ORDER BY emailResponse.isDefault DESC, emailResponse.created DESC
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfloop query="emailResponse">
			
			<cfset dataArray[emailResponse.currentRow]['responseID'] = emailResponse.sID />
			<cfset dataArray[emailResponse.currentRow]['name'] = emailResponse.name />
			<cfset dataArray[emailResponse.currentRow]['content'] = emailResponse.content />

		</cfloop>

		<cfset result['data'] = dataArray />


		<cfset objTools.runtime('get', '/partner/{partnerID}/response', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset objAccum = createObject('component','/resources/private/accum') />
		<cfset responseID = objAccum.newID('secureIDPrefix') />
		<cfset sID = responseID & '-' & createUUID() />


		<cfquery name="emailResponse" datasource="startfly">
		INSERT INTO emailResponse (
		ID,
		sID,
		partnerID,
		name,
		content,
		created
		) VALUES (
		#responseID#,
		'#sID#',
		#internalPartnerID#,
		'#arguments.name#',
		'#arguments.content#',
		NOW()
		)
		</cfquery>


		<cfset result['data']['responseID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['content'] = arguments.content />

		<cfset objTools.runtime('post', '/partner/{partnerID}/response', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
