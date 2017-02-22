<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/passwordreminder" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="username" type="string" required="false" default="" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset err = arrayNew(1) />

		<cfset okToPost = 1 />

		<cfif not isValid('email',arguments.userName)>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Please provide a valid email address') />

		<cfelse>

			<cfquery name="q" datasource="startfly">
				select password    
				FROM partner 
				WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userName#" /> 
				LIMIT 1
			</cfquery>
	
	
			<cfif q.recordCount is 1>
	
				<cfset result['data']['located'] = 1 />

		        <cfset objEmail = createObject('component','resources/private/email') />

		        <cfset emailData = {
		        	sendTo = arguments.userName,
		        	sendFrom = 'noreply@startfly.co.uk',
		        	subject = 'Startfly Partner Password Reminder'
		        } />

		        <cfsavecontent variable="emailData.emailContent">
			        <cfoutput>
			        	<p>
				        	<strong>Your partner password reminder was requested from Startfly.co.uk</strong>
				        </p>
				        <p>Your password is: #q.password#</p>
				        
			        </cfoutput>
		        </cfsavecontent> 

		        <cfset result.emailSend = objEmail.SendMandrillHTML(emailData) />

		
			<cfelse>
				<cfset okToPost = 0 />
				<cfset arrayAppend(err,'Email address is not registered') />
			</cfif>

		</cfif>



		<cfif okToPost is 1>


		<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'An error occurred' />
				<cfset result['status']['errors'] = err />			
		</cfif>
		
		<cfset objTools.runtime('post', '/partner/passwordreminder', (getTickCount() - sTime) ) />
		
	
		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
