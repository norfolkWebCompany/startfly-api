<cfcomponent extends="taffy.core.resource" taffy:uri="/imageLibrary/images" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" default="" />
		<cfargument name="type" type="string" required="true" default="" />
		<cfargument name="selectAgainst" type="string" required="true" default="" />


			<cfset objTools = createObject('component','/resources/private/tools') />

			<cfset sTime = getTickCount() />

			<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />


			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset result['data'] = [] />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />

			<cfswitch expression="#arguments.type#">
				<cfcase value="listing">

					<cfif arguments.selectAgainst neq ''>
						<cfset internalID = objTools.internalID('listing',arguments.selectAgainst) />
					<cfelse>
						<cfset internalID = 0 />
					</cfif>

					<cfquery name="images" datasource="startfly" result="qResult">
					SELECT 
					images.ID,
					images.imagePath,
					listingImages.listingID AS listingID
					FROM images 
					LEFT JOIN listingImages ON images.ID = listingImages.imageID
					WHERE images.archive = 0 
					AND images.ownerID = #internalPartnerID#
					AND images.size = 'cover'
					ORDER BY images.created DESC
					</cfquery>

					<cfset imagesArray = arrayNew(1) />

					<cfloop query="images">
						<cfset imagesArray[images.currentRow]['ID'] = images.ID />
						<cfif internalID is images.listingID>
							<cfset imagesArray[images.currentRow]['selected'] = 1 />
						<cfelse>
							<cfset imagesArray[images.currentRow]['selected'] = 0 />
						</cfif>
						<cfset imagesArray[images.currentRow]['imagePath'] = 'https://beta.startfly.co.uk/images/library/' & images.imagePath />
					</cfloop>

					<cfset result['data'] = imagesArray /> 

				</cfcase>
			</cfswitch>

		<cfset objTools.runtime('get', '/imageLibrary/{partnerID}/images', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>

</cfcomponent>
