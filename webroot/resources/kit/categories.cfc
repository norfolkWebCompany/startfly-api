<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/kit/categories" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="categories" datasource="startfly">
		SELECT 
		kitCategory.*
		FROM kitCategory 
		WHERE 
		(partnerID = #internalPartnerID# AND deleted = 0) 
		OR  
		(partnerID = '0'	AND deleted = 0)
		ORDER BY kitCategory.partnerID, kitCategory.name
		</cfquery>



		<cfif categories.recordCount gt 0>
			
			<cfloop query="categories">
				<cfset result['data'][categories.currentRow]['ID'] = categories.sID />
				<cfset result['data'][categories.currentRow]['name'] = categories.name />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/partner/{partnerID}/kit/categories', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset ID = objAccum.newID('secureIDPrefix') />
		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO kitCategory (
		ID,
		sID,
		partnerID,
		name,
		created
		) VALUES (
		#ID#,
		'#sID#',
		#internalPartnerID#,
		'#arguments.name#',
		NOW()
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />


		<cfset objTools.runtime('post', '/partner/{partnerID}/kit/categories', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
