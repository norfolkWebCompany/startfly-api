<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/qualifications" hint="some hint about this resource">

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
			partnerQualifications.*,
			qualifications.name 
			FROM partnerQualifications 
			LEFT JOIN qualifications ON partnerQualifications.qualificationID = qualifications.ID
			WHERE partnerQualifications.partnerID = #internalPartnerID#
			</cfquery>

			<cfset dataArray = arrayNew(1) />

			<cfloop query="q">
				<cfset dataArray[q.currentRow]['ID'] = q.sID />
				<cfset dataArray[q.currentRow]['qualificationID'] = q.qualificationID />
				<cfset dataArray[q.currentRow]['name'] = q.name />
				<cfset dataArray[q.currentRow]['description'] = q.description />
				<cfset dataArray[q.currentRow]['grade'] = q.grade />
			</cfloop>

			<cfset result['data'] = dataArray />

			<cfset objTools.runtime('get', '/partner/{partnerID}/qualifications', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>



	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="qualification" type="struct" required="true" />

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
			<cfset sID = newID & '-' & createUUID() />

			<cfquery name="q" datasource="startfly">
			INSERT INTO partnerQualifications (
			ID,
			sID,
			partnerID,
			qualificationID,
			grade,
			description
			) VALUES (
			#newID#,
			'#sID#',
			#internalPartnerID#,
			#arguments.qualification.ID#,
			'#arguments.qualification.grade#',
			'#arguments.qualification.description#'
			)
			</cfquery>

			<cfset result['data']['ID'] = sID />

			<cfset objTools.runtime('post', '/partner/{partnerID}/qualifications', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
