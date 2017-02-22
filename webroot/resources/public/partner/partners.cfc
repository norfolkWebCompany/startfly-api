<cfcomponent extends="taffy.core.resource" taffy:uri="/public/partners" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="id" type="string" required="true" />


		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="q" datasource="startfly">
			SELECT 
			partner.*, 
			countries.name AS countryName  
			FROM partner 
			LEFT JOIN countries ON partner.country = countries.ID 
			ORDER BY partner.surname
		</cfquery>



			<cfif q.recordCount gt 0>
	
				<cfset result['data']['ID'] = q.ID />
				<cfset result['data']['firstname'] = q.firstname />
				<cfset result['data']['surname'] = q.surname />
				<cfset result['data']['nickname'] = q.nickname />
				<cfset result['data']['company'] = q.company />
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
				<cfset result['data']['niNumber'] = q.niNumber />
				<cfset result['data']['previewText'] = q.previewText />
				<cfset result['data']['bio'] = q.bio />

				<cfif q.avatar is ''>
					<cfset result['data']['avatar'] = 'https://beta.startfly.co.uk/assets/images/' & 'upload-icon.png' />
				<cfelse>
					<cfset result['data']['avatar'] = 'https://beta.startfly.co.uk/images/partner/' & q.avatar />
				</cfif>

				<cfset result['data']['webURL'] = q.webURL />
				<cfset result['data']['fbURL'] = q.fbURL />
				<cfset result['data']['twitterURL'] = q.twitterURL />
				<cfset result['data']['youtubeURL'] = q.youtubeURL />
				<cfset result['data']['promoURL'] = q.promoURL />
				<cfset result['data']['firstAid'] = q.firstAid />
				<cfset result['data']['publicLi'] = q.publicLi />
				<cfset result['data']['employerLi'] = q.employerLi />
				<cfset result['data']['productLi'] = q.productLi />
				<cfset result['data']['yearEndDay'] = q.yearEndDay />
				<cfset result['data']['yearEndMonth'] = q.yearEndMonth />
				<cfset result['data']['useBusinessName'] = q.useBusinessName />
				<cfset result['data']['vatRegistered'] = q.vatRegistered />


				<cfset result['data']['created'] = dateFormat(q.created, "yyyy-mm-dd") & 'T' & timeFormat(q.created,"HH:mm:ss") & 'Z' />
				<cfset result['data']['dob'] = dateFormat(q.dob, "ddd mmm dd yyyy") & ' ' & timeFormat(q.dob,"HH:mm:ss") & ' GMT+0100 (BST)' />

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
						partner.*, 
						countries.name AS countryName  
						FROM courses 
						INNER JOIN partner ON courses.partnerID = partner.ID 
						LEFT JOIN countries ON partner.country = countries.ID
						WHERE courses.partnerID = #q.ID#
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

			<cfset objTools.runtime('get', '/public/partners', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>



	<cffunction name="post" access="public" output="false">
		<cfargument name="firstname" type="string" required="true" />
		<cfargument name="surname" type="string" required="true" />
		<cfargument name="email" type="string" required="true" default="" />
		<cfargument name="termsAgreed" type="numeric" required="true" default="0" />
		<cfargument name="newsletter" type="numeric" required="true" default="0" />

			<cfset objTools = createObject('component','/resources/private/tools') />
			<cfset sTime = getTickCount() />

			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset result['data'] = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />

			<cfset errorList = arrayNew(1) />

			<cfquery name="emailCheck" datasource="startfly">
			SELECT email 
			FROM partner 
			WHERE email = '#arguments.email#'
			</cfquery>

			<cfif emailCheck.recordCount gt 0>
				<cfset result['status']['statusCode'] = 500 />
				<cfset arrayAppend(errorList,'This email account already exists') /> 
			</cfif>

			<cfif arguments.firstname is ''>
				<cfset result['status']['statusCode'] = 500 />
				<cfset arrayAppend(errorList,'Please enter your firstname') /> 
			</cfif>

			<cfif arguments.surname is ''>
				<cfset result['status']['statusCode'] = 500 />
				<cfset arrayAppend(errorList,'Please enter your surname') /> 
			</cfif>

			<cfif not isValid('email',arguments.email)>
				<cfset result['status']['statusCode'] = 500 />
				<cfset arrayAppend(errorList,'Please enter a valid email address') /> 
			</cfif>

			<cfif len(arguments.mobile) lt 11>
				<cfset result['status']['statusCode'] = 500 />
				<cfset arrayAppend(errorList,'Please enter a valid mobile number') /> 
			</cfif>

			<cfif len(arguments.password) lt 8>
				<cfset result['status']['statusCode'] = 500 />
				<cfset arrayAppend(errorList,'Password must be minimum 8 characters') /> 
			</cfif>

			<cfif arguments.password neq arguments.passwordConfirm>
				<cfset result['status']['statusCode'] = 500 />
				<cfset arrayAppend(errorList,'Password confirmation does not match password') /> 
			</cfif>

			<cfif arguments.termsAgreed is 0>
				<cfset result['status']['statusCode'] = 500 />
				<cfset arrayAppend(errorList,'You must agree to our terms and conditions') /> 
			</cfif>

			<cfif result['status']['statusCode'] is 200>


				<cfset objDates = createObject('component','/resources/private/dates') />
		
				<cfset objAccum = createObject('component','/resources/private/accum') />
				
				<cfset partnerID = objAccum.newID('secureIDPrefix') />
				<cfset sID = objTools.secureID() />

				<cfset activationCode = objAccum.newID('secureIDPrefix') & right(partnerID,4) />

				<cfquery datasource="startfly">
				INSERT INTO partner (
				ID,
				sID,
				firstname,
				surname,
				email,
				landline,
				mobile,
				password,
				termsAgreed,
				newsletter,
				activationCode,
				created
				) VALUES (
				#partnerID#,
				'#sID#',
				'#arguments.firstName#',
				'#arguments.surname#',
				'#arguments.email#',
				'#arguments.landline#',
				'#arguments.mobile#',
				'#arguments.password#',
				#arguments.termsAgreed#,
				#arguments.newsletter#,
				'#activationCode#',
				#objDates.toEpoch(now())#
				) 
				</cfquery>

				<cfset result['data']['partnerID'] = sID />

			<!--- send the activation email --->
            <cfthread action="run" name="activate#partnerID#"> 
		        <cfset objEmailTemplate = createObject('component','resources/private/emailTemplates/partner-activation') />
		        <cfset objEmailTemplate.send(partnerID) />
            </cfthread> 


			<cfelse>
				<cfset result['errors'] = errorList />
			</cfif>



			<cfset objTools.runtime('post', '/public/partners', (getTickCount() - sTime) ) />


		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
