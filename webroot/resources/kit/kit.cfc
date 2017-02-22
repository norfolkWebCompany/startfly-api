<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/kit" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="kit" datasource="startfly">
		SELECT 
		kit.*,
		kitCategory.sID AS categorySID,
		kitCategory.name AS categoryName
		FROM kit 
		INNER JOIN kitCategory ON kit.category = kitCategory.ID
		WHERE kit.partnerID = #internalPartnerID# 
		AND kit.deleted = 0
		ORDER BY kitCategory.name, kit.name
		</cfquery>



		<cfif kit.recordCount gt 0>
			
			<cfloop query="kit">
				<cfset result['data'][kit.currentRow]['ID'] = kit.sID />
				<cfset result['data'][kit.currentRow]['name'] = kit.name />
				<cfset result['data'][kit.currentRow]['category']['ID'] = kit.categorySID />
				<cfset result['data'][kit.currentRow]['category']['name'] = kit.categoryName />
				<cfset result['data'][kit.currentRow]['status'] = kit.status />
				<cfset result['data'][kit.currentRow]['selected'] = kit.selected />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/partner/{partnerID}/kit', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />


		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalCategoryID = objTools.internalID('kitCategory',arguments.category.ID) />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset ID = objAccum.newID('secureIDPrefix') />
		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO kit (
		ID,
		sID,
		partnerID,
		category,
		name,
		status,
		created
		) VALUES (
		#ID#,
		'#sID#',
		#internalPartnerID#,
		#internalCategoryID#,
		'#arguments.name#',
		1,
		NOW()
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['category']['ID'] = arguments.category.ID />
		<cfset result['data']['category']['name'] = arguments.category.name />
		<cfset result['data']['status'] = 1 />
		<cfset result['data']['selected'] = 0 />
		<cfset result['data']['required'] = 0 />
		<cfset result['data']['provided'] = 0 />

		<cfset objTools.runtime('post', '/partner/{partnerID}/kit', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
