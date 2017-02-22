<cfcomponent extends="taffy.core.resource" taffy:uri="/payment/options" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="paymentOptions" datasource="startfly">
		SELECT 
		paymentOptions.*
		FROM paymentOptions 
		WHERE paymentOptions.status = 1 
		ORDER BY paymentOptions.sortOrder
		</cfquery>



		<cfif paymentOptions.recordCount gt 0>
			
			<cfloop query="paymentOptions">
				<cfset result['data'][paymentOptions.currentRow]['ID'] = paymentOptions.ID />
				<cfset result['data'][paymentOptions.currentRow]['name'] = paymentOptions.name />
				<cfset result['data'][paymentOptions.currentRow]['status'] = paymentOptions.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset ID = objAccum.newID('secureIDPrefix') & '-' & createUUID() />
		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO paymentOptions (
		ID,
		sID,
		name,
		status,
		created
		) VALUES (
		#ID#,
		'#sID#',
		'#arguments.name#',
		1,
		NOW()
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
