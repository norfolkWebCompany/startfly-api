<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/profile" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="customerID" type="numeric" required="true" />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="q" datasource="startfly">
			SELECT 
			customer.*,
			(SELECT SUM(valuePaid) FROM bookingDetail WHERE customerID = customer.ID) as spendToDate,
			countries.name AS countryName  
			FROM customer 
			LEFT JOIN countries ON customer.country = countries.ID
			WHERE customer.ID = #arguments.customerID#
		</cfquery>



			<cfif q.recordCount is 1>
	
				<cfset result['data']['userID'] = q.ID />
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

				<cfif q.avatar is ''>
					<cfset result['data']['avatar'] = 'https://beta.startfly.co.uk/assets/images/' & 'upload-icon.png' />
				<cfelse>
					<cfset result['data']['avatar'] = 'https://beta.startfly.co.uk/images/customer/' & q.avatar />
				</cfif>


				<cfset result['data']['created'] = dateFormat(q.created, "yyyy-mm-dd") & 'T' & timeFormat(q.created,"HH:mm:ss") & 'Z' />
				<cfif isDate(q.dob)>
					<cfset result['data']['age'] = dateDiff('yyyy',q.dob,now()) />
				<cfelse>
					<cfset result['data']['age'] = '' />
				</cfif>
				<cfset result['data']['spendToDate'] = numberFormat(q.spendToDate,'.__') />
			


				<cfset emergencyContactArray = arrayNew(1) />

				<cfquery name="emergencyContact" datasource="startfly">
				SELECT 
				emergencyContact.*,
				familyRelationships.name as relationshipName
				FROM emergencyContact 
				INNER JOIN familyRelationships ON emergencyContact.relationship = familyRelationships.ID
				WHERE emergencyContact.customerID = #arguments.customerID#
				</cfquery>



				<cfloop query="emergencyContact">
					<cfset emergencyContactArray[emergencyContact.currentRow]['ID'] = emergencyContact.ID />
					<cfset emergencyContactArray[emergencyContact.currentRow]['firstname'] = emergencyContact.firstname />
					<cfset emergencyContactArray[emergencyContact.currentRow]['surname'] = emergencyContact.surname />
					<cfset emergencyContactArray[emergencyContact.currentRow]['relationship']['ID'] = emergencyContact.relationship />
					<cfset emergencyContactArray[emergencyContact.currentRow]['relationship']['name'] = emergencyContact.relationshipName />
					<cfset emergencyContactArray[emergencyContact.currentRow]['telephoneOne'] = emergencyContact.telephoneOne />
					<cfset emergencyContactArray[emergencyContact.currentRow]['telephoneTwo'] = emergencyContact.telephoneTwo />
				</cfloop>
				<cfset result['data']['emergencyContacts'] = emergencyContactArray />



				<cfset languagesArray = arrayNew(1) />

				<cfquery name="languages" datasource="startfly">
				SELECT 
				languages.* 
				FROM languages 
				ORDER BY languages.name
				</cfquery>


				<cfloop query="languages">
					<cfset languagesArray[languages.currentRow]['ID'] = languages.ID />
					<cfset languagesArray[languages.currentRow]['name'] = languages.name />
					<cfset languagesArray[languages.currentRow]['selected'] = 0 />

					<cfquery name="languagesIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM languagesIndex 
					WHERE customerID = #arguments.customerID# 
					AND prefID = '#languages.ID#'
					</cfquery>

					<cfif languagesIndex.recordCount gt 0>
						<cfset languagesArray[languages.currentRow]['selected'] = 1 />
					</cfif>
				</cfloop>

				<cfset result['data']['languages'] = languagesArray />


				<cfset medicalConditionsArray = arrayNew(1) />

				<cfquery name="medicalConditions" datasource="startfly">
				SELECT 
				medicalConditions.* 
				FROM medicalConditions 
				ORDER BY medicalConditions.name
				</cfquery>


				<cfloop query="medicalConditions">
					<cfset medicalConditionsArray[medicalConditions.currentRow]['ID'] = medicalConditions.ID />
					<cfset medicalConditionsArray[medicalConditions.currentRow]['name'] = medicalConditions.name />
					<cfset medicalConditionsArray[medicalConditions.currentRow]['selected'] = 0 />

					<cfquery name="medicalConditionsIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM medicalConditionsIndex 
					WHERE customerID = #arguments.customerID# 
					AND prefID = '#medicalConditions.ID#'
					</cfquery>

					<cfif medicalConditionsIndex.recordCount gt 0>
						<cfset medicalConditionsArray[medicalConditions.currentRow]['selected'] = 1 />
					</cfif>
				</cfloop>

				<cfset result['data']['medicalConditions'] = medicalConditionsArray />


				<cfset phobiasArray = arrayNew(1) />

				<cfquery name="phobias" datasource="startfly">
				SELECT 
				phobias.* 
				FROM phobias 
				ORDER BY phobias.name
				</cfquery>


				<cfloop query="phobias">
					<cfset phobiasArray[phobias.currentRow]['ID'] = phobias.ID />
					<cfset phobiasArray[phobias.currentRow]['name'] = phobias.name />
					<cfset phobiasArray[phobias.currentRow]['selected'] = 0 />

					<cfquery name="phobiasIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM phobiasIndex 
					WHERE customerID = #arguments.customerID# 
					AND prefID = '#phobias.ID#'
					</cfquery>

					<cfif phobiasIndex.recordCount gt 0>
						<cfset phobiasArray[phobias.currentRow]['selected'] = 1 />
					</cfif>
				</cfloop>

				<cfset result['data']['phobias'] = phobiasArray />


				<cfset foodAllergiesArray = arrayNew(1) />

				<cfquery name="foodAllergies" datasource="startfly">
				SELECT 
				foodAllergies.* 
				FROM foodAllergies 
				ORDER BY foodAllergies.name
				</cfquery>


				<cfloop query="foodAllergies">
					<cfset foodAllergiesArray[foodAllergies.currentRow]['ID'] = foodAllergies.ID />
					<cfset foodAllergiesArray[foodAllergies.currentRow]['name'] = foodAllergies.name />
					<cfset foodAllergiesArray[foodAllergies.currentRow]['selected'] = 0 />

					<cfquery name="foodAllergiesIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM foodAllergiesIndex 
					WHERE customerID = #arguments.customerID# 
					AND prefID = '#foodAllergies.ID#'
					</cfquery>

					<cfif foodAllergiesIndex.recordCount gt 0>
						<cfset foodAllergiesArray[foodAllergies.currentRow]['selected'] = 1 />
					</cfif>
				</cfloop>

				<cfset result['data']['foodAllergies'] = foodAllergiesArray />


				<cfset preferencesArray = arrayNew(1) />

				<cfquery name="preferences" datasource="startfly">
				SELECT 
				preferences.* 
				FROM preferences 
				ORDER BY preferences.name
				</cfquery>


				<cfloop query="preferences">
					<cfset preferencesArray[preferences.currentRow]['ID'] = preferences.ID />
					<cfset preferencesArray[preferences.currentRow]['name'] = preferences.name />
					<cfset preferencesArray[preferences.currentRow]['selected'] = 0 />

					<cfquery name="preferencesIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM preferencesIndex 
					WHERE customerID = #arguments.customerID# 
					AND prefID = '#preferences.ID#'
					</cfquery>

					<cfif preferencesIndex.recordCount gt 0>
						<cfset preferencesArray[preferences.currentRow]['selected'] = 1 />
					</cfif>
				</cfloop>

				<cfset result['data']['preferences'] = preferencesArray />


			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>



	<cffunction name="post" access="public" output="false">
		<cfargument name="bio" type="string" required="false" />


			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />
			<cfset result['status']['userID'] = arguments.customerID />
			<cfset result['status']['bio'] = arguments.bio />
			<cfset result['status']['avatar'] = arguments.avatar />
			<cfset result['status']['languages'] = arguments.languages />

			<cfquery name="q" datasource="startfly">
				UPDATE customer SET 
				add1 = '#arguments.address1#', 
				add2 = '#arguments.address2#', 
				add3 = '#arguments.address3#', 
				town = '#arguments.town#', 
				county = '#arguments.county#', 
				postcode = '#arguments.postcode#', 
				mobile = '#arguments.mobile#',
				landline = '#arguments.landline#',
				email = '#arguments.email#',
				gender = '#arguments.gender#',
				bio = '#arguments.bio#',
				updated = now()
				WHERE ID = #arguments.customerID#
			</cfquery>


		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
