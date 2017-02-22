<cfcomponent extends="taffy.core.resource" taffy:uri="/restriction/categories/{categoryID}/options" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="restrictionOptions" datasource="startfly">
		SELECT 
		restrictionOption.*,
		restrictionCategory.name AS categoryName
		FROM restrictionOption 
		INNER JOIN restrictionCategory ON restrictionOption.category = restrictionCategory.ID
		WHERE restrictionOption.category = #arguments.categoryID# 
		AND restrictionOption.deleted = 0
		ORDER BY restrictionOption.sortOrder, restrictionOption.name
		</cfquery>



		<cfif restrictionOptions.recordCount gt 0>
			
			<cfloop query="restrictionOptions">
				<cfset result['data'][restrictionOptions.currentRow]['ID'] = restrictionOptions.sID />
				<cfset result['data'][restrictionOptions.currentRow]['name'] = restrictionOptions.name />
				<cfset result['data'][restrictionOptions.currentRow]['category']['ID'] = restrictionOptions.category />
				<cfset result['data'][restrictionOptions.currentRow]['category']['name'] = restrictionOptions.categoryName />
				<cfset result['data'][restrictionOptions.currentRow]['status'] = restrictionOptions.status />
				<cfset result['data'][restrictionOptions.currentRow]['selected'] = restrictionOptions.selected />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/restriction/categories/{categoryID}/options', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="category" type="struct" required="true" />
		<cfargument name="selected" type="numeric" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset ID = objAccum.newID('secureIDPrefix') />
		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO restrictionOption (
		ID,
		sID,
		category,
		name,
		selected,
		created
		) VALUES (
		#ID#,
		'#sID#',
		'#arguments.category.ID#',
		'#arguments.name#',
		#arguments.selected#,
		NOW()
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['category']['ID'] = arguments.category.ID />
		<cfset result['data']['category']['name'] = arguments.category.name />
		<cfset result['data']['status'] = 1 />
		<cfset result['data']['selected'] = 0 />


		<cfset objTools.runtime('post', '/restriction/categories/{categoryID}/options', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
