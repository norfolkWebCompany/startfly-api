<cfcomponent extends="taffy.core.resource" taffy:uri="/authenticate" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="username" type="string" required="false" default="" />
		<cfargument name="password" type="string" required="false" default="" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset err = arrayNew(1) />

		<cfset okToPost = 1 />

		<cfif arguments.userName is '' or arguments.password is ''>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Please provide a valid email and password') />

		<cfelse>

			<cfquery name="q" datasource="startfly">
				select ID, sID, firstName, surname, email, showTestContent   
				FROM customer 
				WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userName#" /> 
				AND password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.password#" /> 
				LIMIT 1
			</cfquery>
	
	
			<cfif q.recordCount is 1>
	
				<cfset result['data']['userID'] = q.sID />
				<cfset result['data']['authenticated'] = 1 />
				<cfset result['data']['firstname'] = q.firstname />
				<cfset result['data']['surname'] = q.surname />
				<cfset result['data']['email'] = q.email />
				<cfset result['data']['token'] = createUUID() />
				<cfset result['data']['role'] = 'public' />

				<cfset loginTime = objDates.toEpoch(now()) />

				<cfquery datasource="startfly">
				UPDATE customer SET 
				totalLogins = totalLogins + 1,
				lastLogin = #loginTime# 
				WHERE ID = #q.ID#
				</cfquery>


				<cfquery datasource="startfly">
				INSERT INTO logAuthentication (
				userID,
				created,
				source,
				direction
				) VALUES (
				#q.ID#,
				#loginTime#,
				'customer',
				'in'
				) 
				</cfquery>

		
			<cfelse>
				<cfset okToPost = 0 />
				<cfset arrayAppend(err,'Please provide a valid email and password') />
			</cfif>

		</cfif>



		<cfif okToPost is 1>


		<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'An error occurred' />
				<cfset result['status']['errors'] = err />			
		</cfif>
		
		
		<cfset objTools.runtime('post', '/authenticate', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
