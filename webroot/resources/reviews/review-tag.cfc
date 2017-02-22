<cfcomponent extends="taffy.core.resource" taffy:uri="/review/tag" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfif arguments.tagged is 0>
			<cfquery datasource="startfly" result="qResult">
			UPDATE reviews 
			SET tagged = 1
			WHERE reviews.sID = '#arguments.reviewID#'
			</cfquery>
		<cfelse>
			<cfquery datasource="startfly" result="qResult">
			UPDATE reviews 
			SET tagged = 0
			WHERE reviews.sID = '#arguments.reviewID#'
			</cfquery>
		</cfif>

		<cfset result['data'] = arguments />

		<cfset objTools.runtime('post', '/review/tag', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
