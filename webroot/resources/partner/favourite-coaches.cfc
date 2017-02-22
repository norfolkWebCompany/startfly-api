<cfcomponent extends="taffy.core.resource" taffy:uri="/coachee/{ID}/favourites/coaches" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="internalID" datasource="startfly">
		SELECT ID 
		FROM coachee 
		WHERE secureID = '#arguments.ID#'
		</cfquery>


		<cfquery name="q" datasource="startfly">
		SELECT 
		coach.*, 
		countries.name AS countryName  
		FROM favouriteCoaches 
		INNER JOIN coach ON favouriteCoaches.coachID = coach.ID 
		LEFT JOIN countries ON coach.country = countries.ID 
		WHERE favouriteCoaches.coacheeID = #internalID.ID#
		</cfquery>


			<cfset dataArray = arrayNew(1) />

			<cfif q.recordCount gt 0>

				<cfloop query="q">
					
	
				<cfset dataArray[q.currentRow]['ID'] = q.secureID />
				<cfset dataArray[q.currentRow]['firstname'] = q.firstname />
				<cfset dataArray[q.currentRow]['surname'] = q.surname />
				<cfset dataArray[q.currentRow]['address1'] = q.add1 />
				<cfset dataArray[q.currentRow]['address2'] = q.add2 />
				<cfset dataArray[q.currentRow]['address3'] = q.add3 />
				<cfset dataArray[q.currentRow]['town'] = q.town />
				<cfset dataArray[q.currentRow]['county'] = q.county />
				<cfset dataArray[q.currentRow]['country'] = q.country />
				<cfset dataArray[q.currentRow]['countryName'] = q.countryName />
				<cfset dataArray[q.currentRow]['postcode'] = q.postcode />
				<cfset dataArray[q.currentRow]['landline'] = q.landline />
				<cfset dataArray[q.currentRow]['mobile'] = q.mobile />
				<cfset dataArray[q.currentRow]['email'] = q.email />
				<cfset dataArray[q.currentRow]['gender'] = q.gender />
				<cfset dataArray[q.currentRow]['previewText'] = q.previewText />
				<cfset dataArray[q.currentRow]['bio'] = q.bio />
				<cfset dataArray[q.currentRow]['avatar'] = q.avatar />
				<cfset dataArray[q.currentRow]['created'] = dateFormat(q.created, "yyyy-mm-dd") & 'T' & timeFormat(q.created,"HH:mm:ss") & 'Z' />



				<cfquery name="categories" datasource="startfly">
				SELECT 
				courseCategory.name,
				courseCategory.URL,
				courseCategory.secureID 
				FROM courseCategoryIndex 
				INNER JOIN courseCategory ON courseCategoryIndex.categoryID = courseCategory.ID 
				INNER JOIN courses ON courseCategoryIndex.courseID = courses.ID 
				WHERE courses.coachID = #q.ID# 
				</cfquery>

				<cfset dataArray[q.currentRow]['categories'] = arrayNew(1) />

				<cfloop query="categories">
					<cfset  dataArray[q.currentRow]['categories'][categories.currentRow]['categoryID'] = categories.secureID />
					<cfset  dataArray[q.currentRow]['categories'][categories.currentRow]['pageURL'] = categories.URL />
					<cfset  dataArray[q.currentRow]['categories'][categories.currentRow]['categoryName'] = categories.name />
				</cfloop>


				<cfset dataArray[q.currentRow]['courses'] = arrayNew(1) />

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

							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['courseID'] = courses.courseID />
							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['courseName'] = courses.name />
							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['value'] = courses.value />
							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['howOften'] = courses.howOften />
							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['rating'] = courses.rating />
							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['featured'] = courses.featured />
							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['image'] = courses.image />
							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['previewText'] = courses.previewText />
							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['created'] = dateFormat(courses.created, "yyyy-mm-dd") & 'T' & timeFormat(courses.created,"HH:mm:ss") & 'Z' />

							<cfset dataArray[q.currentRow]['courses'][courses.currentRow]['categories'] = arrayNew(1) />

							<cfloop query="categories">
								<cfset  dataArray[q.currentRow]['courses'][courses.currentRow]['categories'][categories.currentRow]['categoryID'] = categories.secureID />
								<cfset  dataArray[q.currentRow]['courses'][courses.currentRow]['categories'][categories.currentRow]['pageURL'] = categories.URL />
								<cfset  dataArray[q.currentRow]['courses'][courses.currentRow]['categories'][categories.currentRow]['categoryName'] = categories.name />
							</cfloop>

						</cfif>		

				</cfloop>

				<cfset result['data'] = dataArray />

			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>




</cfcomponent>
