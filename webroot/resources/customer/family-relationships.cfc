<cfcomponent extends="taffy.core.resource" taffy:uri="/familyrelationships" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="familyRelationships" datasource="startfly">
		SELECT 
		familyRelationships.*
		FROM familyRelationships 
		WHERE familyRelationships.status = 1 
		ORDER BY familyRelationships.sortOrder
		</cfquery>



		<cfif familyRelationships.recordCount gt 0>
			
			<cfloop query="familyRelationships">
				<cfset result['data'][familyRelationships.currentRow]['ID'] = familyRelationships.sID />
				<cfset result['data'][familyRelationships.currentRow]['name'] = familyRelationships.name />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/familyrelationships', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly" result="qResult">
		INSERT INTO familyRelationships (
		sID,
		name
		) VALUES (
		'#sID#',
		'#arguments.name#'
		)
		</cfquery>

		<cfset result['data']['ID'] = qResult.generatedKey />
		<cfset result['data']['name'] = arguments.name />

		<cfset objTools.runtime('post', '/familyrelationships', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
