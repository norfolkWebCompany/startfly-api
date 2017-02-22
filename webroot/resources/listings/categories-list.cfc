<cfcomponent extends="taffy.core.resource" taffy:uri="/coursecategories/list" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="categories" datasource="startfly">
		SELECT 
		courseCategory.*
		FROM courseCategory 
		WHERE courseCategory.status = 1 
		AND parentID > 0 
		ORDER BY courseCategory.name
		</cfquery>


		<cfset courses = arrayNew(1) />

		<cfif categories.recordCount gt 0>
			

			<cfloop query="categories">
				
				<cfset thisName = categories.name />

				<cfif categories.parentID neq 0>

					<cfquery name="subCat" dbtype="query">
					SELECT 
					name,
					ID,
					parentID 
					FROM categories 
					WHERE id = #categories.parentID#
					</cfquery>

					<cfif subCat.recordCount is 1>
						<cfset thisName = subCat.name & ' / ' & thisName />


						<cfquery name="subCat2" dbtype="query">
						SELECT name 
						FROM categories 
						WHERE id = #subCat.parentID#
						</cfquery>

						<cfif subCat2.recordCount is 1>
							<cfset thisName = subCat2.name & ' / ' & thisName />
						</cfif>


					</cfif>


				</cfif>


				<cfset courses[categories.currentRow]['ID'] = categories.ID />
				<cfset courses[categories.currentRow]['name'] = thisName />

			</cfloop>


			<cfset result['data'] = courses />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/coursecategories/list', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="params" type="struct" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="allCategories" datasource="startfly">
		SELECT 
		courseCategory.ID,
		courseCategory.parentID,
		courseCategory.name,
		courseCategory.level
		FROM courseCategory 
		WHERE courseCategory.status = 1 
		ORDER BY courseCategory.name 
		</cfquery>

		<cfset result['recordCount']['allCategories'] = allCategories.recordcount />


		<cfquery name="categories" datasource="startfly">
		SELECT 
		ID,
		parentID,
		name,
		level
		FROM courseCategory
		WHERE name 
		LIKE '%#arguments.params.name#%'
		ORDER BY name 
		</cfquery>



		<cfset result['recordCount']['categories'] = categories.recordcount />
	

		<cfset courses = arrayNew(1) />

		<cfif categories.recordCount gt 0>
			
			<cfset x = 0 />
			<cfloop query="categories">


				<cfswitch expression="#categories.level#">

					<cfcase value="4">

								<cfquery name="level4" dbtype="query">
								SELECT 
								name,
								ID,
								parentID 
								FROM allCategories  
								WHERE ID = #categories.parentID#
								</cfquery>
								<cfset result['recordCount']['level4'] = level4.recordcount />

								<cfloop query="level4">
										<cfset thisName = level4.name & ' - ' & categories.name />

										<cfset x = x + 1 />
										<cfset courses[x]['ID'] = categories.ID />
										<cfset courses[x]['name'] = thisName />
								</cfloop>

					</cfcase>

					<cfcase value="3">

								<cfquery name="level2" dbtype="query">
								SELECT 
								name,
								ID,
								parentID 
								FROM allCategories  
								WHERE ID = #categories.parentID#
								</cfquery>
								<cfset result['recordCount']['level32'] = level2.recordcount />

								<cfloop query="level2">

										<cfset thisName = level2.name & ' - ' & categories.name  />

										<cfset x = x + 1 />
										<cfset courses[x]['ID'] = categories.ID />
										<cfset courses[x]['name'] = thisName />

								</cfloop>

								<cfquery name="level3" dbtype="query">
								SELECT 
								name,
								ID,
								parentID 
								FROM allCategories  
								WHERE parentID = #categories.ID#
								</cfquery>
								<cfset result['recordCount']['level3'] = level3.recordcount />

								<cfloop query="level3">

										<cfset thisName = categories.name & ' - ' & level3.name />

										<cfset x = x + 1 />
										<cfset courses[x]['ID'] = level3.ID />
										<cfset courses[x]['name'] = thisName />


											<cfquery name="level4" dbtype="query">
											SELECT 
											name,
											ID,
											parentID 
											FROM allCategories  
											WHERE parentID = #level3.ID#
											</cfquery>
											<cfset result['recordCount']['level34'] = level4.recordcount />

											<cfloop query="level4">
													<cfset thisName = thisName & ' - ' &  level4.name />

													<cfset x = x + 1 />
													<cfset courses[x]['ID'] = level4.ID />
													<cfset courses[x]['name'] = thisName />
											</cfloop>

								</cfloop>

					</cfcase>



					<cfcase value="2">

						<cfset thisName = categories.name />

						<cfset x = x + 1 />
						<cfset courses[x]['ID'] = categories.ID />
						<cfset courses[x]['name'] = thisName />

								<cfquery name="level2" dbtype="query">
								SELECT 
								name,
								ID,
								parentID 
								FROM allCategories  
								WHERE parentID = #categories.ID#
								</cfquery>
								<cfset result['recordCount']['level2'] = level2.recordcount />

								<cfloop query="level2">

										<cfset thisName = categories.name & ' - ' & level2.name />

										<cfset x = x + 1 />
										<cfset courses[x]['ID'] = level2.ID />
										<cfset courses[x]['name'] = thisName />

											<cfquery name="level3" dbtype="query">
											SELECT 
											name,
											ID,
											parentID 
											FROM allCategories  
											WHERE parentID = #level2.ID#
											</cfquery>
											<cfset result['recordCount']['level23'] = level3.recordcount />

											<cfloop query="level3">

													<cfset thisName = categories.name & ' - ' & level3.name />

													<cfset x = x + 1 />
													<cfset courses[x]['ID'] = level3.ID />
													<cfset courses[x]['name'] = thisName />


														<cfquery name="level4" dbtype="query">
														SELECT 
														name,
														ID,
														parentID 
														FROM allCategories  
														WHERE parentID = #level3.ID#
														</cfquery>
														<cfset result['recordCount']['level34'] = level4.recordcount />

														<cfloop query="level4">
																<cfset thisName = thisName & ' - ' &  level4.name />

																<cfset x = x + 1 />
																<cfset courses[x]['ID'] = level4.ID />
																<cfset courses[x]['name'] = thisName />
														</cfloop>

											</cfloop>
								</cfloop>

					</cfcase>


					<cfcase value="1">


					</cfcase>
				</cfswitch>

				

			</cfloop>


			<cfset result['data'] = courses />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('post', '/coursecategories/list', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
