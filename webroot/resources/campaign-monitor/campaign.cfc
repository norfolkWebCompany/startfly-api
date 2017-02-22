<cfcomponent extends="taffy.core.resource" taffy:uri="/campaignreg" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="firstname" type="string" required="false" default="" />
		<cfargument name="surname" type="string" required="false" default="" />
		<cfargument name="email" type="string" required="false" default="" />



		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset okToPost = 1 />
		
		<cfif arguments.firstName is '' or arguments.surname is ''>
			<cfset okToPost = 0 />
			<cfset errorText = 'Please provide your name' />
		</cfif>

		<cfif not isValid('email',arguments.email)>
			<cfset okToPost = 0 />
			<cfset errorText = 'Please provide a value email address' />
		</cfif>
	
		<cfif okToPost is 1>
			
			
			<cfset fullName = arguments.firstname & ' ' & arguments.surname />

			<cfhttp 
				method="post"
				URL="http://www.pushemailmarketing.com/t/r/s/hjdkttt/"
				result="res"
				timeout="5">
					
					<cfhttpparam type="formfield" name="cm_name" value="#fullName#" />
					<cfhttpparam type="formfield" name="cm-hjdkttt-hjdkttt" value="#arguments.email#" />
					
			</cfhttp>

			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />

		<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Please provide a valid name and email address' />
		</cfif>

		
		
	
		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
