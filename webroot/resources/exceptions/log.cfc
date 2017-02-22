<cfcomponent extends="taffy.core.resource" taffy:uri="/exceptions/log" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset result['data']['arguments'] = arguments />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
