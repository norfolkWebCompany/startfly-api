<cfcomponent extends="taffy.core.resource" taffy:uri="/campaign/lists" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<!---

		<cfhttp 
		url="https://api.createsend.com/api/v3.1/clients/ec2c2ff8c102c189d663e23d6857afd6/lists.json" 
		method="get"
		username="72d3c8a2cbbf08caa7dab9a8f2174386" 
		password="">
		<cfhttpparam type="header" name="accept-encoding" value="no-compression" />
		<cfhttpparam type="xml" value="" />
		</cfhttp>


		<cfset result.data = cfhttp.FileContent>

		--->

		<cfquery name="lists" datasource="startfly">
		SELECT * 
		FROM campaigns 
		ORDER BY ID
		</cfquery>

		<cfset listData = arrayNew(1) />

		<cfloop query="lists">
			<cfset listData[lists.currentRow]['ID'] = lists.ID />
			<cfset listData[lists.currentRow]['listID'] = lists.listID />
			<cfset listData[lists.currentRow]['listName'] = lists.listName />
		</cfloop>

		<cfset result['data'] = listData />
		
		<cfreturn representationOf(result).withStatus(200).withMime('text') />
	</cffunction>

</cfcomponent>
