<cfcomponent extends="taffy.core.resource" taffy:uri="/restrictionOptions" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="genre" datasource="startfly">
		SELECT 
		restrictionGenre.*
		FROM restrictionGenre 
		ORDER BY restrictionGenre.sortOrder, restrictionGenre.name
		</cfquery>

		<cfset genreArray = arrayNew(1) />
		<cfloop query="genre">
			<cfset genreArray[genre.currentRow]['ID'] = genre.sID />
			<cfset genreArray[genre.currentRow]['name'] = genre.name />
			<cfset genreArray[genre.currentRow]['maxAge'] = genre.maxAge />
			<cfset genreArray[genre.currentRow]['minAgeSelected'] = genre.minAge />
			<cfset genreArray[genre.currentRow]['maxAgeSelected'] = genre.maxAge />
			<cfset genreArray[genre.currentRow]['selected'] = genre.selected />
			<cfset genreArray[genre.currentRow]['score'] = genre.score />
			
			<cfquery name="categories" datasource="startfly">
			SELECT 
			restrictionCategory.*
			FROM restrictionCategory 
			WHERE restrictionCategory.genre = #genre.ID#
			ORDER BY restrictionCategory.sortOrder, restrictionCategory.name
			</cfquery>

			<cfset categoryArray = arrayNew(1) />
			<cfloop query="categories">
				<cfset categoryArray[categories.currentRow]['ID'] = categories.sID />
				<cfset categoryArray[categories.currentRow]['name'] = categories.name />
				<cfset categoryArray[categories.currentRow]['description'] = categories.description />
				<cfset categoryArray[categories.currentRow]['collapsed'] = categories.collapsed />
				<cfset categoryArray[categories.currentRow]['inMemberships'] = categories.inMemberships />
				<cfset categoryArray[categories.currentRow]['selected'] = categories.selected />

				<cfquery name="options" datasource="startfly">
				SELECT 
				restrictionOption.*
				FROM restrictionOption 
				WHERE restrictionOption.category = #categories.ID# 
				AND restrictionOption.deleted = 0
				ORDER BY restrictionOption.sortOrder, restrictionOption.name
				</cfquery>

				<cfset optionsArray = arrayNew(1) />
				<cfloop query="options">
					<cfset optionsArray[options.currentRow]['ID'] = options.sID />
					<cfset optionsArray[options.currentRow]['name'] = options.name />
					<cfset optionsArray[options.currentRow]['status'] = options.status />
					<cfset optionsArray[options.currentRow]['selected'] = options.selected />
				</cfloop>
				<cfset categoryArray[categories.currentRow]['options'] = optionsArray />

			</cfloop>

			<cfset genreArray[genre.currentRow]['categories'] = categoryArray />


		</cfloop>

		<cfset result['data'] = genreArray />

		<cfset objTools.runtime('get', '/restrictionOptions', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
