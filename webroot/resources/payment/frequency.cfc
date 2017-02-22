<cfcomponent extends="taffy.core.resource" taffy:uri="/payment/frequency" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="paymentFrequency" datasource="startfly">
		SELECT 
		paymentFrequency.*
		FROM paymentFrequency 
		WHERE paymentFrequency.status = 1 
		ORDER BY paymentFrequency.sortOrder
		</cfquery>



		<cfif paymentFrequency.recordCount gt 0>
			
			<cfloop query="paymentFrequency">
				<cfset result['data'][paymentFrequency.currentRow]['ID'] = paymentFrequency.ID />
				<cfset result['data'][paymentFrequency.currentRow]['name'] = paymentFrequency.name />
				<cfset result['data'][paymentFrequency.currentRow]['status'] = paymentFrequency.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset ID = objAccum.newID('secureIDPrefix') & '-' & createUUID() />

		<cfquery datasource="startfly">
		INSERT INTO paymentFrequency (
		ID,
		name,
		status
		) VALUES (
		'#ID#',
		'#arguments.name#',
		1
		)
		</cfquery>

		<cfset result['data']['ID'] = ID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
