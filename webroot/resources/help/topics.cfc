<cfcomponent extends="taffy.core.resource" taffy:uri="/helpgroup/{groupID}" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = arrayNew(1) />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="help" datasource="startfly">
		SELECT 
		help.*,
		helpGroup.sID as groupSID,
		helpGroup.name as groupName
		FROM help 
		INNER JOIN helpGroup ON help.groupID = helpGroup.ID
		WHERE help.status = 1 
		AND helpGroup.sID = '#arguments.groupID#'
		ORDER BY help.sortOrder
		</cfquery>



		<cfloop query="help">
			<cfset result['data'][help.currentRow]['ID'] = help.sID />
			<cfset result['data'][help.currentRow]['groupID'] = help.groupSID />
			<cfset result['data'][help.currentRow]['groupName'] = help.groupName />
			<cfset result['data'][help.currentRow]['title'] = help.title />
			<cfset result['data'][help.currentRow]['content'] = help.content />
			<cfset result['data'][help.currentRow]['status'] = help.status />
		</cfloop>


		<cfset objTools.runtime('get', '/helpgroup/{groupID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="title" type="string" required="true" />
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

		<cfset internalGroupID = objTools.internalID('helpGroup',arguments.groupID) />

		<cfquery datasource="startfly">
		INSERT INTO help (
		sID,
		groupID,
		created,
		title,
		content
		) VALUES (
		'#sID#',
		#internalGroupID#,
		NOW(),
		'#arguments.title#',
		'#arguments.content#'
		)
		</cfquery>

		<cfset result['data']['ID'] = sID />
		<cfset result['data']['name'] = arguments.title />
		<cfset result['data']['status'] = 1 />

		<cfset objTools.runtime('post', '/helpgroup/{groupID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
