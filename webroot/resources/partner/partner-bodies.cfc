<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/bodies" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />

			<cfset objTools = createObject('component','/resources/private/tools') />

			<cfset sTime = getTickCount() />

			<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />


			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset result['data'] = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />


			<cfquery name="q" datasource="startfly">
			SELECT 
			partnerProfessionalBodies.*,
			professionalBodies.name 
			FROM partnerProfessionalBodies 
			LEFT JOIN professionalBodies ON partnerProfessionalBodies.bodyID = professionalBodies.ID
			WHERE partnerProfessionalBodies.partnerID = #internalPartnerID#
			</cfquery>

			<cfset dataArray = arrayNew(1) />

			<cfloop query="q">
				<cfset dataArray[q.currentRow]['ID'] = q.sID />
				<cfset dataArray[q.currentRow]['bodyID'] = q.bodyID />
				<cfset dataArray[q.currentRow]['name'] = q.name />
				<cfset dataArray[q.currentRow]['description'] = q.description />
				<cfset dataArray[q.currentRow]['membershipNumber'] = q.membershipNumber />
			</cfloop>

			<cfset result['data'] = dataArray />

			<cfset objTools.runtime('get', '/partner/{partnerID}/bodies', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>



	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="body" type="struct" required="true" />

			<cfset objTools = createObject('component','/resources/private/tools') />

			<cfset sTime = getTickCount() />

			<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset result['data'] = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />


			<cfset objAccum = createObject('component','/resources/private/accum') />
			<cfset newID = objAccum.newID('secureIDPrefix') />
			<cfset sID = createUUID() />

			<cfquery name="q" datasource="startfly">
			INSERT INTO partnerProfessionalBodies (
			ID,
			sID,
			partnerID,
			bodyID,
			membershipNumber,
			description
			) VALUES (
			#newID#,
			'#sID#',
			#internalPartnerID#,
			#arguments.body.ID#,
			'#arguments.body.membershipNumber#',
			'#arguments.body.description#'
			)
			</cfquery>

			<cfset result['data']['ID'] = sID />

			<cfset objTools.runtime('post', '/partner/{partnerID}/bodies', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
