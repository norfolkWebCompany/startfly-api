<cfcomponent extends="taffy.core.resource" taffy:uri="/campaign/client" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />



		<cfhttp 
		url="https://api.createsend.com/api/v3.1/clients.json" 
		method="get"
		username="72d3c8a2cbbf08caa7dab9a8f2174386" 
		password="">
		<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		<cfhttpparam type="xml" value="" />
		</cfhttp>


		<cfset result.data = cfhttp.FileContent>



		
		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
