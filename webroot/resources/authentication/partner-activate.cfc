<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/activate" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" default="" />
		<cfargument name="activationCode" type="string" required="true" default="" />


		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />
		<cfset result['activated'] = 0 />


		<cfset err = arrayNew(1) />

		<cfset okToPost = 1 />

		<cfif arguments.activationCode is ''>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Please provide a valid activation code') />

		<cfelse>

			<cfquery name="q" datasource="startfly">
				select activated, ID   
				FROM partner 
				WHERE activationCode = '#arguments.activationCode#' 
				LIMIT 1
			</cfquery>
	
	
			<cfif q.recordCount is 1>
	
				<cfquery datasource="startfly">
				UPDATE partner SET 
				totalLogins = totalLogins + 1,
				lastLogin = #objDates.toEpoch(now())#,
				activated = 1 
				WHERE ID = '#q.ID#'
				</cfquery>

				<cfset result['data']['activated'] = 1 />
			<cfelse>
				<cfset okToPost = 0 />
				<cfset arrayAppend(err,'Please provide a valid activation code') />
			</cfif>

		</cfif>



		<cfif okToPost is 1>


		<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'An error occurred' />
				<cfset result['errors'] = err />			
		</cfif>
		
		
	
		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
