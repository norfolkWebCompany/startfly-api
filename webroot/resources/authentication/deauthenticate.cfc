<cfcomponent extends="taffy.core.resource" taffy:uri="/deauthenticate" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="userID" type="string" required="false" default="" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />


		<cfset internalCustomerID = objTools.internalID('customer',arguments.userID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset err = arrayNew(1) />

		<cfset okToPost = 1 />

		<cfif arguments.userID neq ''>

			<cfset logoutTime = objDates.toEpoch(now()) />

			<cfquery datasource="startfly">
			INSERT INTO logAuthentication (
			userID,
			created,
			source,
			direction
			) VALUES (
			#internalCustomerID#,
			#logoutTime#,
			'customer',
			'out'
			) 
			</cfquery>

		</cfif>
		
		
	
		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
