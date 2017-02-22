<cfcomponent extends="taffy.core.resource" taffy:uri="/cancellationpolicy" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="cancellationPolicy" datasource="startfly">
		SELECT 
		cancellationPolicy.*
		FROM cancellationPolicy 
		WHERE cancellationPolicy.status = 1 
		ORDER BY cancellationPolicy.sortOrder
		</cfquery>

		<cfif cancellationPolicy.recordCount gt 0>
			
			<cfloop query="cancellationPolicy">
				<cfset result['data'][cancellationPolicy.currentRow]['ID'] = cancellationPolicy.sID />
				<cfset result['data'][cancellationPolicy.currentRow]['name'] = cancellationPolicy.name />
				<cfset result['data'][cancellationPolicy.currentRow]['content'] = objTools.toHTML(cancellationPolicy.content) /> 
				replace(cancellationPolicy.content,chr(13),'<br /><br />','ALL') />
				<cfset result['data'][cancellationPolicy.currentRow]['status'] = cancellationPolicy.status />
			</cfloop>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/cancellationPolicy', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset ID = objAccum.newID('secureIDPrefix') />
		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO cancellationPolicy (
		ID,
		sID,
		name,
		content,
		status
		) VALUES (
		#ID#,
		'#sID#',
		'#arguments.name#',
		'#arguments.content#',
		1
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.name />
		<cfset result['data']['status'] = 1 />

		<cfset objTools.runtime('post', '/cancellationpolicy', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
