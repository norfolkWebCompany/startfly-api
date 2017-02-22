<cfcomponent>
	<cffunction name="build" access="public" returntype="struct">
		<cfargument name="data" type="query" required="yes" />

		<cfset result = {} />

			<cfset result['partnerID'] = arguments.data.partnerSID />
			<cfset result['created'] = objDates.fromEpoch(arguments.data.partnerCreated,'JSON') />
			<cfif arguments.data.useBusinessName is 0>
				<cfset result['name'] = arguments.data.firstname & ' ' & arguments.data.surname />
				<cfset result['firstname'] = arguments.data.firstname />
			<cfelse>
				<cfset result['name'] = arguments.data.company />
				<cfset result['firstname'] = arguments.data.company />
			</cfif>
			<cfset result['nickname'] = arguments.data.nickname />
			<cfset result['preview'] = arguments.data.partnerPreview />
			<cfset result['gender'] = arguments.data.gender />
			<cfset result['imageURL'] = 'https://beta.startfly.co.uk/images/partner/' & arguments.data.avatar />

			<cfif 
				arguments.data.webURL neq '' OR 
				arguments.data.fbURL neq '' OR 
				arguments.data.twitterURL neq '' OR 
				arguments.data.youtubeURL neq '' OR 
				arguments.data.instagramURL neq ''>
					
				<cfset result['hasSocial'] = 1 />
			<cfelse>
				<cfset result['hasSocial'] = 0 />
			</cfif>

			<cfset result['webURL'] = arguments.data.webURL />
			<cfset result['fbURL'] = arguments.data.fbURL />
			<cfset result['twitterURL'] = arguments.data.twitterURL />
			<cfset result['instagramURL'] = arguments.data.instagramURL />
			<cfset result['youtubeURL'] = arguments.data.youtubeURL />


		<cfreturn result />
	</cffunction>
</cfcomponent>