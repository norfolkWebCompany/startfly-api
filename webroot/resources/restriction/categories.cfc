<cfcomponent extends="taffy.core.resource" taffy:uri="/restriction/categories" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="categories" datasource="startfly">
		SELECT 
		restrictionCategory.*,
		restrictionGenre.name AS genreName
		FROM restrictionCategory 
		INNER JOIN restrictionGenre ON restrictionCategory.genre = restrictionGenre.ID
		ORDER BY restrictionCategory.sortOrder, restrictionCategory.name
		</cfquery>

		<cfif categories.recordCount gt 0>
			
			<cfloop query="categories">
				<cfset result['data'][categories.currentRow]['ID'] = categories.sID />
				<cfset result['data'][categories.currentRow]['name'] = categories.name />
				<cfset result['data'][categories.currentRow]['genre']['ID'] = categories.genre />
				<cfset result['data'][categories.currentRow]['genre']['name'] = categories.genreName />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/restriction/categories', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="genre" type="struct" required="true" />

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
		INSERT INTO restrictionCategory (
		ID,
		sID,
		genre,
		name,
		created
		) VALUES (
		#ID#,
		'#sID#',
		'#arguments.genre.ID#',
		'#arguments.name#',
		NOW()
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['genre'] = arguments.genre />


		<cfset objTools.runtime('post', '/restriction/categories', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
