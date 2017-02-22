<cfcomponent extends="taffy.core.resource" taffy:uri="/coach/{id}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="id" type="string" required="true" />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="q" datasource="startfly">
			SELECT 
			coach.*, 
			countries.name AS countryName  
			FROM coach 
			LEFT JOIN countries ON coach.country = countries.ID
			WHERE secureID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" />
		</cfquery>



			<cfif q.recordCount gt 0>
	
				<cfset result['data']['ID'] = q.secureID />
				<cfset result['data']['firstname'] = q.firstname />
				<cfset result['data']['surname'] = q.surname />
				<cfset result['data']['address1'] = q.add1 />
				<cfset result['data']['address2'] = q.add2 />
				<cfset result['data']['address3'] = q.add3 />
				<cfset result['data']['town'] = q.town />
				<cfset result['data']['county'] = q.county />
				<cfset result['data']['country'] = q.country />
				<cfset result['data']['countryName'] = q.countryName />
				<cfset result['data']['postcode'] = q.postcode />
				<cfset result['data']['landline'] = q.landline />
				<cfset result['data']['mobile'] = q.mobile />
				<cfset result['data']['email'] = q.email />
				<cfset result['data']['gender'] = q.gender />
				<cfset result['data']['bio'] = q.bio />
				<cfset result['data']['avatar'] = q.avatar />
				<cfset result['data']['created'] = dateFormat(q.created, "yyyy-mm-dd") & 'T' & timeFormat(q.created,"HH:mm:ss") & 'Z' />

				<cfset result['data']['courses'] = arrayNew(1) />

						<cfquery name="courses" datasource="startfly">
						SELECT 
						courses.secureID AS courseID,
						courses.ID AS courseInternalID,
						courses.name,
						courses.value,
						courses.rating,
						courses.featured,
						courses.image,
						courses.previewText,
						courses.created,
						courses.howOften,
						coach.*, 
						countries.name AS countryName  
						FROM courses 
						INNER JOIN coach ON courses.coachID = coach.ID 
						LEFT JOIN countries ON coach.country = countries.ID
						WHERE courses.coachID = #q.ID#
						</cfquery>



						<cfif courses.recordCount gt 0>
				
							<cfquery name="categories" datasource="startfly">
							SELECT 
							courseCategory.name,
							courseCategory.URL,
							courseCategory.secureID 
							FROM courseCategoryIndex 
							INNER JOIN courseCategory ON courseCategoryIndex.categoryID = courseCategory.ID 
							WHERE courseCategoryIndex.courseID = #courses.courseInternalID# 
							</cfquery>

							<cfset result['data']['courses'][courses.currentRow]['courseID'] = courses.courseID />
							<cfset result['data']['courses'][courses.currentRow]['courseName'] = courses.name />
							<cfset result['data']['courses'][courses.currentRow]['value'] = courses.value />
							<cfset result['data']['courses'][courses.currentRow]['rating'] = courses.rating />
							<cfset result['data']['courses'][courses.currentRow]['howOften'] = courses.howOften />
							<cfset result['data']['courses'][courses.currentRow]['featured'] = courses.featured />
							<cfset result['data']['courses'][courses.currentRow]['image'] = courses.image />
							<cfset result['data']['courses'][courses.currentRow]['previewText'] = courses.previewText />
							<cfset result['data']['courses'][courses.currentRow]['created'] = dateFormat(courses.created, "yyyy-mm-dd") & 'T' & timeFormat(courses.created,"HH:mm:ss") & 'Z' />

							<cfset result['data']['courses'][courses.currentRow]['categories'] = arrayNew(1) />

							<cfloop query="categories">
								<cfset  result['data']['courses'][courses.currentRow]['categories'][categories.currentRow]['categoryID'] = categories.secureID />
								<cfset  result['data']['courses'][courses.currentRow]['categories'][categories.currentRow]['pageURL'] = categories.URL />
								<cfset  result['data']['courses'][courses.currentRow]['categories'][categories.currentRow]['categoryName'] = categories.name />
							</cfloop>

						</cfif>			

			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>




</cfcomponent>
