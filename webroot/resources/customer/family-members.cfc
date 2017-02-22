<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/familymembers" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">
		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />


		<cfquery name="q" datasource="startfly">
			SELECT 
			customer.*,
			(SELECT SUM(valuePaid) FROM bookingDetail WHERE customerID = customer.ID) as spendToDate,
			countries.name AS countryName  
			FROM customer 
			LEFT JOIN countries ON customer.country = countries.ID
			WHERE customer.parentID = #internalCustomerID# 
			AND customer.deleted = 0
			ORDER BY customer.firstname
		</cfquery>


			<cfset dataArray = arrayNew(1) />

				<cfloop query="q">
					
		
					<cfset dataArray[q.currentRow]['ID'] = q.sID />
					<cfset dataArray[q.currentRow]['parentID'] = arguments.customerID />
					<cfset dataArray[q.currentRow]['relationship'] = q.relationship />
					<cfset dataArray[q.currentRow]['firstname'] = q.firstname />
					<cfset dataArray[q.currentRow]['surname'] = q.surname />
					<cfset dataArray[q.currentRow]['gender'] = q.gender />
					<cfset dataArray[q.currentRow]['bio'] = q.bio />
					<cfset dataArray[q.currentRow]['lastBooked'] = q.lastBooked />
					<cfset dataArray[q.currentRow]['totalBookings'] = q.totalBookings />


					<cfset dataArray[q.currentRow]['created'] = objDates.fromEpoch(q.created,'JSON') /> />
					<cfif q.dob neq 0>
						<cfset dataArray[q.currentRow]['dob'] = objDates.fromEpoch(q.dob,'JSON') />
					<cfelse>
						<cfset dataArray[q.currentRow]['dob'] = '' />
					</cfif>

					<cfif q.dob neq 0>
						<cfset dataArray[q.currentRow]['age'] = ceiling(( ( objDates.toEpoch(now()) - q.dob ) / 31556926 )) />
					<cfelse>
						<cfset dataArray[q.currentRow]['age'] = '' />
					</cfif>

					<cfset dataArray[q.currentRow]['spendToDate'] = numberFormat(q.spendToDate,'.__') />

				<cfif q.avatar is ''>
					<cfset dataArray[q.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/' & 'profile-avatar.png' />
				<cfelse>
					<cfset dataArray[q.currentRow]['avatar'] = q.avatar />
				</cfif>

				</cfloop>

				<cfset result['data'] = dataArray />


		<cfset objTools.runtime('get', '/customer/{customerID}/familymembers', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>




	<cffunction name="post" access="public" output="false">
		<cfargument name="firstname" type="string" required="true" />
		<cfargument name="surname" type="string" required="true" />
		<cfargument name="newsletter" type="numeric" required="true" default="0" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

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

			<cfset objAccum = createObject('component','/resources/private/accum') />

			<cfset dob = objDates.toCF(arguments.dob,'JSON','/') />
			<cfset dob = objDates.toEpoch(dob) />
			<cfset created = objDates.toEpoch(now()) />


			<cfset familyID = objAccum.newID('secureIDPrefix') />
			<cfset sID = objTools.secureID() />

			<cfset result['data']['ID'] = customerID />


			<cfquery datasource="startfly">
			INSERT INTO customer (
			ID,
			sID,
			parentID,
			relationship,
			firstname,
			surname,
			gender,
			dob,
			bio,
			newsletter,
			avatar,
			created,
			lastLogin,
			totalLogins
			) VALUES (
			#familyID#,
			'#sID#',
			#internalCustomerID#,
			#arguments.relationship#,
			'#arguments.firstname#',
			'#arguments.surname#',
			'#arguments.gender#',
			#dob#,
			'#arguments.bio#',
			#arguments.newsletter#,
			'#arguments.avatar#',
			#created#,
			#created#,
			1
			)
			</cfquery>


			<cfloop index="i1" from="1" to="#arrayLen(arguments.languages)#">
				<cfif arguments.languages[i1]['selected'] is 1>
					<cfquery datasource="startfly">
						INSERT INTO languagesIndex (
						prefID,
						customerID
						) VALUES (
						#objTools.internalID('languages',arguments.languages[i1]['ID'])#,
						#familyID#
						)
					</cfquery>
				</cfif>
			</cfloop>

			<cfloop index="i1" from="1" to="#arrayLen(arguments.medicalConditions)#">
				<cfif arguments.medicalConditions[i1]['selected'] is 1>
					
					<cfquery datasource="startfly">
					INSERT INTO medicalConditionsIndex (
					prefID,
					customerID
					) VALUES (
					#objTools.internalID('medicalConditions',arguments.medicalConditions[i1]['ID'])#,
					#familyID#
					)
					</cfquery>
				</cfif>
			</cfloop>

			<cfloop index="i1" from="1" to="#arrayLen(arguments.phobias)#">
				<cfif arguments.phobias[i1]['selected'] is 1>
					<cfquery datasource="startfly">
						INSERT INTO phobiasIndex (
						prefID,
						customerID
						) VALUES (
						#objTools.internalID('phobias',arguments.phobias[i1]['ID'])#,
						#familyID#
						)
					</cfquery>
				</cfif>
			</cfloop>

			<cfloop index="i1" from="1" to="#arrayLen(arguments.foodAllergies)#">
				<cfif arguments.foodAllergies[i1]['selected'] is 1>
					<cfquery datasource="startfly">
						INSERT INTO foodAllergiesIndex (
						prefID,
						customerID
						) VALUES (
						#objTools.internalID('foodAllergies',arguments.foodAllergies[i1]['ID'])#,
						#familyID#
						)
					</cfquery>
				</cfif>
			</cfloop>

			<cfloop index="i1" from="1" to="#arrayLen(arguments.preferences)#">
				<cfif arguments.preferences[i1]['selected'] is 1>
					<cfquery datasource="startfly">
						INSERT INTO preferencesIndex (
						prefID,
						customerID
						) VALUES (
						#objTools.internalID('preferences',arguments.preferences[i1]['ID'])#,
						#familyID#
						)
					</cfquery>
				</cfif>
			</cfloop>
		
			<cfset result['arguments'] = arguments />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'An error occurred' />
			<cfset result['errors'] = err />			
		</cfif>

		<cfset objTools.runtime('post', '/customer/{customerID}/familymembers', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>