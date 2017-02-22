<cfcomponent extends="taffy.core.resource" taffy:uri="/register" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="firstname" type="string" required="true" />
		<cfargument name="surname" type="string" required="true" />
		<cfargument name="email" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />
		<cfargument name="passwordConfirmation" type="string" required="true" />
		<cfargument name="newsletter" type="numeric" required="true" default="0" />


		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

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

		<cfif arguments.email is ''>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Provide a valid email address') />

			<cfelse>

				<cfquery name="emailCheck" datasource="startfly">
				SELECT email 
				FROM customer 
				WHERE email = '#arguments.email#'
				</cfquery>

				<cfif emailCheck.recordcount gt 0>
					<cfset okToPost = 0 />
					<cfset arrayAppend(err,'Email address already in use') />
				</cfif>

		</cfif>

		<cfif len(arguments.password) lt 6>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Password must be 6 or more characters') />

		<cfelse>
			<cfif arguments.password neq arguments.passwordConfirmation>
				<cfset okToPost = 0 />
				<cfset arrayAppend(err,'Password confirmation does not match') />
			</cfif>
		</cfif>

		<cfif okToPost is 1>


			<cfset objDates = createObject('component','/resources/private/dates') />
			<cfset objAccum = createObject('component','/resources/private/accum') />


			<cfset ID = objAccum.newID('secureIDPrefix') />
			<cfset sID = objTools.secureID() />



			<cfset result['data']['ID'] = sID />

			<cfquery datasource="startfly">
			INSERT INTO customer (
			ID,
			sID,
			firstname,
			surname,
			email,
			password,
			newsletter,
			created,
			lastLogin,
			totalLogins
			) VALUES (
			#ID#,
			'#sID#',
			'#arguments.firstname#',
			'#arguments.surname#',
			'#arguments.email#',
			'#arguments.password#',
			#arguments.newsletter#,
			#objDates.toEpoch(now())#,
			#objDates.toEpoch(now())#,
			1
			)
			</cfquery>

			<!--- send the reg --->
            <cfthread action="run" name="customerreg#ID#"> 
		        <cfset objEmailTemplate = createObject('component','/resources/private/emailTemplates/customer-registration') />
		        <cfset objEmailTemplate.send(ID) />
            </cfthread> 


		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'An error occurred' />
			<cfset result['errors'] = err />			
		</cfif>



		<cfset objTools.runtime('post', '/register', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>