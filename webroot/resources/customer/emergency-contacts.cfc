<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/emergencycontacts" hint="some hint about this resource">
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
		emergencyContact.*,
		familyRelationships.name as relationshipName
		FROM emergencyContact 
		INNER JOIN familyRelationships ON emergencyContact.relationship = familyRelationships.ID
		WHERE emergencyContact.customerID = #internalCustomerID#
		ORDER BY emergencyContact.ID DESC
		</cfquery>


			<cfset dataArray = arrayNew(1) />

			<cfloop query="q">
				<cfset dataArray[q.currentRow]['ID'] = q.sID />
				<cfset dataArray[q.currentRow]['customerID'] = q.customerID />
				<cfset dataArray[q.currentRow]['relationship'] = q.relationship />
				<cfset dataArray[q.currentRow]['firstname'] = q.firstname />
				<cfset dataArray[q.currentRow]['surname'] = q.surname />
				<cfset dataArray[q.currentRow]['telephoneOne'] = q.telephoneOne />
				<cfset dataArray[q.currentRow]['telephoneTwo'] = q.telephoneTwo />
				<cfset dataArray[q.currentRow]['created'] = q.created />
			</cfloop>

			<cfset result['data'] = dataArray />


		<cfset objTools.runtime('get', '/customer/emergencycontacts', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>




	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		<cfset internalRelationshipID = objTools.internalID('familyRelationships',arguments.relationship.ID) />

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

			<cfset sID = objTools.secureID() />

			<cfset result['data']['ID'] = sID />


			<cfquery datasource="startfly">
			INSERT INTO emergencyContact (
			sID,
			customerID,
			relationship,
			firstname,
			surname,
			telephoneOne,
			telephoneTwo,
			created
			) VALUES (
			'#sID#',
			#internalCustomerID#,
			#internalRelationshipID#,
			'#arguments.firstname#',
			'#arguments.surname#',
			'#arguments.telephoneOne#',
			'#arguments.telephoneTwo#',
			NOW()
			)
			</cfquery>

			<cfset result['arguments'] = arguments />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'An error occurred' />
			<cfset result['errors'] = err />			
		</cfif>

		<cfset objTools.runtime('post', '/customer/emergencycontacts', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="patch" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		<cfset internalEmergencyContactID = objTools.internalID('emergencyContact',arguments.ID) />
		<cfset internalRelationshipID = objTools.internalID('familyRelationships',arguments.relationship.ID) />

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


 			<cfquery datasource="startfly">
			UPDATE emergencyContact SET
			relationship = #internalRelationshipID#,
			firstname = '#arguments.firstname#',
			surname = '#arguments.surname#',
			telephoneOne = '#arguments.telephoneOne#',
			telephoneTwo = '#arguments.telephoneTwo#'
			WHERE sID = '#arguments.ID#'
			</cfquery>

			<cfset result['arguments'] = arguments />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'An error occurred' />
			<cfset result['errors'] = err />			
		</cfif>

		<cfset objTools.runtime('patch', '/customer/emergencycontacts', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

	<cffunction name="delete" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset internalEmergencyContactID = objTools.internalID('emergencyContact',arguments.ID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		DELETE FROM emergencyContact 
		WHERE ID = #internalEmergencyContactID#
		)
		</cfquery>

		<cfset objTools.runtime('delete', '/customer/emergencycontacts', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>