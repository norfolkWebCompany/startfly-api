<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/familymember/{memberID}" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset internalFamilyID = objTools.internalID('customer',arguments.memberID) />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="q" datasource="startfly">
			SELECT 
			customer.*,
			(SELECT SUM(valuePaid) FROM bookingDetail WHERE customerID = customer.ID) as spendToDate,
			countries.name AS countryName  
			FROM customer 
			LEFT JOIN countries ON customer.country = countries.ID
			WHERE customer.ID = #internalFamilyID# 
			AND customer.deleted = 0
			ORDER BY customer.firstname
		</cfquery>

		<cfif q.recordCount is 1>
			
			<cfset result['data']['ID'] = arguments.memberID />
			<cfset result['data']['parentID'] = arguments.customerID />
			<cfset result['data']['relationship'] = q.relationship />
			<cfset result['data']['firstname'] = q.firstname />
			<cfset result['data']['surname'] = q.surname />
			<cfset result['data']['gender'] = q.gender />
			<cfset result['data']['bio'] = q.bio />
			<cfset result['data']['lastBooked'] = q.lastBooked />
			<cfset result['data']['totalBookings'] = q.totalBookings />
			<cfset result['data']['spendToDate'] = numberFormat(q.spendToDate,'.__') />

			<cfset result['data']['created'] = objDates.fromEpoch(q.created,'JSON') /> />
			<cfif q.dob neq 0>
				<cfset result['data']['dob'] = objDates.fromEpoch(q.dob,'JSON') />
			<cfelse>
				<cfset result['data']['dob'] = '' />
			</cfif>

			<cfif q.dob neq 0>
				<cfset result['data']['age'] = ceiling(( ( objDates.toEpoch(now()) - q.dob ) / 31556926 )) />
			<cfelse>
				<cfset result['data']['age'] = '' />
			</cfif>


			<cfif q.avatar is ''>
				<cfset result['data']['avatar'] = 'https://beta.startfly.co.uk/images/' & 'profile-avatar.png' />
			<cfelse>
				<cfset result['data']['avatar'] = q.avatar />
			</cfif>


				<cfset emergencyContactArray = arrayNew(1) />

				<cfquery name="emergencyContact" datasource="startfly">
				SELECT 
				emergencyContact.*
				FROM emergencyContact 
				WHERE emergencyContact.customerID = #internalFamilyID#
				</cfquery>



				<cfloop query="emergencyContact">
					<cfset emergencyContactArray[emergencyContact.currentRow]['ID'] = emergencyContact.sID />
					<cfset emergencyContactArray[emergencyContact.currentRow]['firstname'] = emergencyContact.firstname />
					<cfset emergencyContactArray[emergencyContact.currentRow]['surname'] = emergencyContact.surname />
					<cfset emergencyContactArray[emergencyContact.currentRow]['relationship'] = emergencyContact.relationship />
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
					<cfset languagesArray[languages.currentRow]['ID'] = languages.sID />
					<cfset languagesArray[languages.currentRow]['name'] = languages.name />
					<cfset languagesArray[languages.currentRow]['selected'] = 0 />

					<cfquery name="languagesIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM languagesIndex 
					WHERE customerID = #internalFamilyID# 
					AND prefID = #languages.ID#
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
					<cfset medicalConditionsArray[medicalConditions.currentRow]['ID'] = medicalConditions.sID />
					<cfset medicalConditionsArray[medicalConditions.currentRow]['name'] = medicalConditions.name />
					<cfset medicalConditionsArray[medicalConditions.currentRow]['selected'] = 0 />

					<cfquery name="medicalConditionsIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM medicalConditionsIndex 
					WHERE customerID = #internalFamilyID# 
					AND prefID = #medicalConditions.ID#
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
					<cfset phobiasArray[phobias.currentRow]['ID'] = phobias.sID />
					<cfset phobiasArray[phobias.currentRow]['name'] = phobias.name />
					<cfset phobiasArray[phobias.currentRow]['selected'] = 0 />

					<cfquery name="phobiasIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM phobiasIndex 
					WHERE customerID = #internalFamilyID# 
					AND prefID = #phobias.ID#
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
					<cfset foodAllergiesArray[foodAllergies.currentRow]['ID'] = foodAllergies.sID />
					<cfset foodAllergiesArray[foodAllergies.currentRow]['name'] = foodAllergies.name />
					<cfset foodAllergiesArray[foodAllergies.currentRow]['selected'] = 0 />

					<cfquery name="foodAllergiesIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM foodAllergiesIndex 
					WHERE customerID = #internalFamilyID# 
					AND prefID = #foodAllergies.ID#
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
					<cfset preferencesArray[preferences.currentRow]['ID'] = preferences.sID />
					<cfset preferencesArray[preferences.currentRow]['name'] = preferences.name />
					<cfset preferencesArray[preferences.currentRow]['selected'] = 0 />

					<cfquery name="preferencesIndex" datasource="startfly">
					SELECT 
					prefID 
					FROM preferencesIndex 
					WHERE customerID = #internalFamilyID# 
					AND prefID = #preferences.ID#
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


		<cfset objTools.runtime('get', '/customer/{customerID}/familymember/{memberID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

	<cffunction name="patch" access="public" output="false">
		<cfargument name="firstname" type="string" required="true" />
		<cfargument name="surname" type="string" required="true" />
		<cfargument name="newsletter" type="numeric" required="true" default="0" />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset internalFamilyID = objTools.internalID('customer',arguments.memberID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset err = arrayNew(1) />

		<cfset okToPost = 1 />

		<cfif arguments.firstname is ''>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Firstname cannot be empty') />
		</cfif>

		<cfif arguments.surname is ''>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Surname cannot be empty') />
		</cfif>

		<cfif okToPost is 1>

			<cfset dob = objDates.toCF(arguments.dob,'JSON','/') />
			<cfset dob = objDates.toEpoch(dob) />
			<cfset updated = objDates.toEpoch(now()) />


			<cfquery datasource="startfly">
			UPDATE customer SET 
			firstname = '#arguments.firstname#',
			surname = '#arguments.surname#',
			relationship = #arguments.relationship#,
			gender = '#arguments.gender#',
			dob = #dob#,
			bio = '#arguments.bio#',
			updated = #updated#
			WHERE ID = #internalFamilyID#
			</cfquery>


			<cfquery datasource="startfly">
				DELETE FROM languagesIndex WHERE customerID = #internalFamilyID#
			</cfquery>


			<cfloop index="i1" from="1" to="#arrayLen(arguments.languages)#">
				<cfif arguments.languages[i1]['selected'] is 1>
					<cfquery datasource="startfly">
						INSERT INTO languagesIndex (
						prefID,
						customerID
						) VALUES (
						#objTools.internalID('languages',arguments.languages[i1]['ID'])#,
						#internalFamilyID#
						)
					</cfquery>
				</cfif>
			</cfloop>
		

			<cfquery datasource="startfly">
				DELETE FROM medicalConditionsIndex WHERE customerID = #internalFamilyID#
			</cfquery>


			<cfloop index="i1" from="1" to="#arrayLen(arguments.medicalConditions)#">
				<cfif arguments.medicalConditions[i1]['selected'] is 1>
					<cfquery datasource="startfly">
						INSERT INTO medicalConditionsIndex (
						prefID,
						customerID
						) VALUES (
						#objTools.internalID('medicalConditions',arguments.medicalConditions[i1]['ID'])#,
						#internalFamilyID#
						)
					</cfquery>
				</cfif>
			</cfloop>


			<cfquery datasource="startfly">
				DELETE FROM phobiasIndex WHERE customerID = #internalFamilyID#
			</cfquery>


			<cfloop index="i1" from="1" to="#arrayLen(arguments.phobias)#">
				<cfif arguments.phobias[i1]['selected'] is 1>
					<cfquery datasource="startfly">
						INSERT INTO phobiasIndex (
						prefID,
						customerID
						) VALUES (
						#objTools.internalID('phobias',arguments.phobias[i1]['ID'])#,
						#internalFamilyID#
						)
					</cfquery>
				</cfif>
			</cfloop>


			<cfquery datasource="startfly">
				DELETE FROM foodAllergiesIndex WHERE customerID = #internalFamilyID#
			</cfquery>


			<cfloop index="i1" from="1" to="#arrayLen(arguments.foodAllergies)#">
				<cfif arguments.foodAllergies[i1]['selected'] is 1>
					<cfquery datasource="startfly">
						INSERT INTO foodAllergiesIndex (
						prefID,
						customerID
						) VALUES (
						#objTools.internalID('foodAllergies',arguments.foodAllergies[i1]['ID'])#,
						#internalFamilyID#
						)
					</cfquery>
				</cfif>
			</cfloop>

			<cfquery datasource="startfly">
				DELETE FROM preferencesIndex WHERE customerID = #internalFamilyID#
			</cfquery>


			<cfloop index="i1" from="1" to="#arrayLen(arguments.preferences)#">
				<cfif arguments.preferences[i1]['selected'] is 1>
					<cfquery datasource="startfly">
						INSERT INTO preferencesIndex (
						prefID,
						customerID
						) VALUES (
						#objTools.internalID('preferences',arguments.preferences[i1]['ID'])#,
						#internalFamilyID#
						)
					</cfquery>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'An error occurred' />
			<cfset result['errors'] = err />			
		</cfif>

		<cfset result['arguments'] = arguments />

		<cfset objTools.runtime('post', '/customer/{customerID}/familymember/{memberID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>