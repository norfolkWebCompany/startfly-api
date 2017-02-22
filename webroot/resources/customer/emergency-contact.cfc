<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/emergencycontact/{ID}" hint="some hint about this resource">
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


		<cfset objTools.runtime('get', '/customer/emergencycontact/{ID}', (getTickCount() - sTime) ) />

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
		</cfquery>

		<cfset objTools.runtime('delete', '/customer/emergencycontact/{ID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>