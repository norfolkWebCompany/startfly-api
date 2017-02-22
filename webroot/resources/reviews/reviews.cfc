<cfcomponent extends="taffy.core.resource" taffy:uri="/reviews" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="customerID" type="string" required="true" />
		<cfargument name="type" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset sID = objTools.secureID() />

		<cfswitch expression="#arguments.type#">
			<cfcase value="listing">
				
				<cfset internalListingID = objTools.internalID('listing',arguments.listingID) />

				<cfquery name="partner" datasource="startfly">
				SELECT 
				partnerID 
				FROM listing 
				WHERE ID = #internalListingID#
				</cfquery>

				<cfquery datasource="startfly" result="qResult">
				INSERT INTO reviews (
				sID,
				type,
				customerID,
				listingID,
				partnerID,
				rating,
				comment,
				created
				) VALUES (
				'#sID#',
				'#arguments.type#',
				#internalCustomerID#,
				#internalListingID#,
				#partner.partnerID#,
				#arguments.rating#,
				'#arguments.comment#',
				NOW()
				)
				</cfquery>


			</cfcase>
			<cfcase value="partner">
				
				<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

				
			</cfcase>
			<cfdefaultcase>
				
			</cfdefaultcase>
		</cfswitch>

		<cfset result['data']['ID'] = sID />

		<cfset objTools.runtime('post', '/reviews', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
