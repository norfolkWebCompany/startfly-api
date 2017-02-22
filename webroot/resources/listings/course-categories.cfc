<cfcomponent extends="taffy.core.resource" taffy:uri="/coursecategories" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="level1" datasource="startfly">
		SELECT 
		courseCategory.*
		FROM courseCategory 
		WHERE courseCategory.status = 1 
		AND courseCategory.parentID = 0 
		ORDER BY courseCategory.sortOrder, coursecategory.name
		</cfquery>


		<cfset level1Array = arrayNew(1) />

		<cfif level1.recordCount gt 0>
			

			<cfloop query="level1">
				

				<cfset level1Array[level1.currentRow]['ID'] = level1.ID />
				<cfset level1Array[level1.currentRow]['name'] = level1.name />
				<cfset level1Array[level1.currentRow]['parentID'] = level1.parentID />
				<cfset level1Array[level1.currentRow]['familyID'] = level1.familyID />
				<cfset level1Array[level1.currentRow]['level'] = level1.level />
<!--- 				<cfset level1Array[level1.currentRow]['sortOrder'] = level1.sortOrder />
				<cfset level1Array[level1.currentRow]['icon'] = level1.icon />
				<cfset level1Array[level1.currentRow]['image'] = level1.image />
 --->				<cfset level1Array[level1.currentRow]['pageURL'] = level1.URL />


				<cfquery name="level2" datasource="startfly">
				SELECT 
				courseCategory.*
				FROM courseCategory 
				WHERE courseCategory.status = 1 
				AND courseCategory.parentID = #level1.ID# 
				ORDER BY courseCategory.sortOrder, coursecategory.name
				</cfquery>

				<cfset level2Array = arrayNew(1) />

				<cfif level2.recordCount gt 0>
				
					<cfloop query="level2">


						<cfset level2Array[level2.currentRow]['ID'] = level2.ID />
						<cfset level2Array[level2.currentRow]['name'] = level2.name />
						<cfset level2Array[level2.currentRow]['parentID'] = level2.parentID />
						<cfset level2Array[level2.currentRow]['familyID'] = level2.familyID />
						<cfset level2Array[level2.currentRow]['level'] = level2.level />
<!--- 						<cfset level2Array[level2.currentRow]['sortOrder'] = level2.sortOrder />
						<cfset level2Array[level2.currentRow]['icon'] = level2.icon />
						<cfset level2Array[level2.currentRow]['image'] = level2.image />
 --->						<cfset level2Array[level2.currentRow]['pageURL'] = level2.URL />

									<cfquery name="level3" datasource="startfly">
									SELECT 
									courseCategory.*
									FROM courseCategory 
									WHERE courseCategory.status = 1 
									AND courseCategory.parentID = #level2.ID# 
									AND courseCategory.level = 3
									ORDER BY courseCategory.sortOrder, coursecategory.name
									</cfquery>

									<cfset level3Array = arrayNew(1) />

									<cfif level3.recordCount gt 0>
									
										<cfloop query="level3">


											<cfset level3Array[level3.currentRow]['ID'] = level3.ID />
											<cfset level3Array[level3.currentRow]['name'] = level3.name />
											<cfset level3Array[level3.currentRow]['parentID'] = level3.parentID />
											<cfset level3Array[level3.currentRow]['familyID'] = level3.familyID />
											<cfset level3Array[level3.currentRow]['level'] = level3.level />
<!--- 											<cfset level3Array[level3.currentRow]['sortOrder'] = level3.sortOrder />
											<cfset level3Array[level3.currentRow]['icon'] = level3.icon />
											<cfset level3Array[level3.currentRow]['image'] = level3.image />
 --->											<cfset level3Array[level3.currentRow]['pageURL'] = level3.URL />



													<cfquery name="level4" datasource="startfly">
													SELECT 
													courseCategory.*
													FROM courseCategory 
													WHERE courseCategory.status = 1 
													AND courseCategory.parentID = #level3.ID# 
													AND courseCategory.level = 4
													ORDER BY courseCategory.sortOrder, coursecategory.name
													</cfquery>

													<cfset level4Array = arrayNew(1) />

													<cfif level4.recordCount gt 0>
													
														<cfloop query="level4">


															<cfset level4Array[level4.currentRow]['ID'] = level4.ID />
															<cfset level4Array[level4.currentRow]['name'] = level4.name />
															<cfset level4Array[level4.currentRow]['parentID'] = level4.parentID />
															<cfset level4Array[level4.currentRow]['familyID'] = level4.familyID />
															<cfset level4Array[level4.currentRow]['level'] = level4.level />
<!--- 															<cfset level4Array[level4.currentRow]['sortOrder'] = level4.sortOrder />
															<cfset level4Array[level4.currentRow]['icon'] = level4.icon />
															<cfset level4Array[level4.currentRow]['image'] = level4.image />
 --->															<cfset level4Array[level4.currentRow]['pageURL'] = level4.URL />

														</cfloop>

													</cfif>	
				
													<cfset level3Array[level3.currentRow]['subCategories'] = level4Array />

										</cfloop>


									</cfif>

									<cfset level2Array[level2.currentRow]['subCategories'] = level3Array />

					</cfloop>


				</cfif>
					<cfset level1Array[level1.currentRow]['subCategories'] = level2Array />
				
			</cfloop>


			<cfset result['data'] = level1Array />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>


		<cfset objTools.runtime('get', '/coursecategories', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
