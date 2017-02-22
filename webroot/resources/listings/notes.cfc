<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/listing/{listingID}/notes" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="notes" datasource="startfly">
		SELECT * 
		FROM listingNotes 
		WHERE listingID = '#arguments.listingID#' 
		and partnerID = '#arguments.partnerID#' 
		ORDER BY created DESC
		</cfquery>

		<cfset noteArray = arrayNew(1) />
		<cfloop query="notes">
			<cfset noteArray[notes.currentRow]['ID'] = notes.ID />
			<cfset noteArray[notes.currentRow]['text'] = notes.text />
			<cfset noteArray[notes.currentRow]['created'] = dateFormat(notes.created, "yyyy-mm-dd") & 'T' & timeFormat(notes.created,"HH:mm:ss") & 'Z' />
		</cfloop>

		<cfset result['data'] = noteArray />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


	<cffunction name="post" access="public" output="false">

		<cfset objAccum = createObject('component','/resources/private/accum') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset noteID = objAccum.newID('secureIDPrefix') & '-' & createUUID() />


		<cfquery datasource="startfly">
		INSERT INTO listingNotes (
		ID,
		partnerID,
		listingID,
		text,
		created
		) VALUES (
		'#noteID#',
		'#arguments.partnerID#',
		'#arguments.listingID#',
		'#arguments.text#',
		NOW()
		)
		</cfquery>


		<cfset result['data']['ID'] = noteID />
		<cfset result['data']['status'] = 1 />
		<cfset result['data']['arguments'] = arguments />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
