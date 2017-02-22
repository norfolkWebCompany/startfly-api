<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/bankAccount" hint="some hint about this resource">

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
				bankAccount.* 
				FROM bankAccount  
				WHERE partnerID = #internalPartnerID#
			</cfquery>

			<cfset result['data']['accountID'] = '' />
			<cfset result['data']['accountName'] = '' />
			<cfset result['data']['accountNumber'] = '' />
			<cfset result['data']['sortCodePart1'] = '' />
			<cfset result['data']['sortCodePart2'] = '' />
			<cfset result['data']['sortCodePart3'] = '' />
			<cfset result['data']['created'] = '' />

			<cfif q.recordCount gt 0>
				<cfset result['data']['accountID'] = q.accountID />
				<cfset result['data']['partnerID'] = q.partnerID />
				<cfset result['data']['accountName'] = q.accountName />
				<cfset result['data']['accountNumber'] = q.accountNumber />
				<cfset result['data']['sortCodePart1'] = q.sortCodePart1 />
				<cfset result['data']['sortCodePart2'] = q.sortCodePart2 />
				<cfset result['data']['sortCodePart3'] = q.sortCodePart3 />
				<cfset result['data']['created'] = dateFormat(q.created, "ddd mmm dd yyyy") & ' ' & timeFormat(q.created,"HH:mm:ss") & ' GMT+0100 (BST)' />

			</cfif>

			<cfset objTools.runtime('get', '/partner/{partnerID}/bankAccount', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>



	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="accountID" type="string" required="true" />
		<cfargument name="accountName" type="string" required="true" />
		<cfargument name="accountNumber" type="string" required="true" />
		<cfargument name="sortCodePart1" type="string" required="true" />
		<cfargument name="sortCodePart2" type="string" required="true" />
		<cfargument name="sortCodePart3" type="string" required="true" />

			<cfset objTools = createObject('component','/resources/private/tools') />

			<cfset sTime = getTickCount() />

			<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset result['data'] = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />

			<cfquery name="thisAccount" datasource="startfly">
			SELECT * 
			FROM bankAccount 
			WHERE accountID = '#arguments.accountID#'
			</cfquery>

			<cfif thisAccount.recordCount is 1>

				<cfquery datasource="startfly">
				UPDATE bankAccount SET 
				accountName = '#arguments.accountName#',
				accountNumber = '#arguments.accountNumber#', 
				sortCodePart1 = '#arguments.sortCodePart1#',
				sortCodePart2 = '#arguments.sortCodePart2#',
				sortCodePart3 = '#arguments.sortCodePart3#'
				WHERE sID = '#arguments.accountID#' 
				AND partnerID = #internalPartnerID#
				</cfquery>

				<cfset result['data']['accountExisted'] = 1 />

			<cfelse>

				<cfset objAccum = createObject('component','/resources/private/accum') />
				<cfset newID = objAccum.newID('secureIDPrefix') />
				<cfset sID = newID & '-' & createUUID() />


				<cfquery datasource="startfly">
				INSERT INTO bankAccount (
				accountID,
				sID,
				partnerID,
				accountName,
				accountNumber,
				sortCodePart1,
				sortCodePart2,
				sortCodePart3,
				created
				) VALUES (
				#newID#,
				'#sID#',
				#internalPartnerID#,
				'#arguments.accountName#',
				'#arguments.accountNumber#',
				'#arguments.sortCodePart1#',
				'#arguments.sortCodePart2#',
				'#arguments.sortCodePart3#',
				NOW()
				) 
				</cfquery>

				<cfset result['data']['accountExisted'] = 0 />
				<cfset result['data']['accountID'] = sID />

			</cfif>

			<cfset objTools.runtime('post', '/partner/{partnerID}/bankAccount', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
