<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/locations/{locationID}" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="locations" datasource="startfly">
		SELECT 
		locations.*,
		countries.name AS countryName  
		FROM locations 
		INNER JOIN countries ON locations.country = countries.ID 
		WHERE locations.status = 1 
		AND partnerID = #internalPartnerID#
		AND locations.sID = '#arguments.locationID#'
		</cfquery>


		<cfset data = structNew() />

		<cfif locations.recordCount gt 0>
			
			<cfset result['data']['locationID'] = locations.sID />
			<cfset result['data']['name'] = locations.name />
			<cfset result['data']['address1'] = locations.add1 />
			<cfset result['data']['address2'] = locations.add2 />
			<cfset result['data']['address3'] = locations.add3 />
			<cfset result['data']['town'] = locations.town />
			<cfset result['data']['county'] = locations.county />
			<cfset result['data']['country'] = locations.country />
			<cfset result['data']['countryName'] = locations.countryName />
			<cfset result['data']['postcode'] = locations.postcode />
			<cfset result['data']['latitude'] = locations.latitude />
			<cfset result['data']['longitude'] = locations.longitude />
			<cfset result['data']['homeAddress'] = locations.homeAddress />
			<cfset result['data']['hideAddress'] = locations.hideAddress />

			<cfquery name="facilities" datasource="startfly">
			SELECT facility 
			FROM locationFacilities 
			WHERE locationID = #locations.ID# 
			AND partnerID = #internalPartnerID#
			</cfquery>

			<cfset facilitiesArray = arrayNew(1) />
			<cfloop query="facilities">
				<cfset facilitiesArray[facilities.currentRow][facilities.facility]['selected'] = true />
			</cfloop>

			<cfset result['data']['facilities'] = facilitiesArray />

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset objTools.runtime('get', '/partner/{partnerID}/locations/{locationID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="patch" access="public" output="false">


		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
		<cfset internalLocationID = objTools.internalID('locations',arguments.locationID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE locations SET 
		name = '#arguments.name#',
		add1 = '#arguments.address1#', 
		add2 = '#arguments.address2#', 
		add3 = '#arguments.address3#', 
		town = '#arguments.town#', 
		county = '#arguments.county#', 
		country = '#arguments.country#', 
		postcode = '#arguments.postcode#', 
		latitude = '#arguments.latitude#', 
		longitude = '#arguments.longitude#',
		homeAddress = #arguments.homeAddress#,
		hideAddress = #arguments.hideAddress# 
		WHERE ID = #internalLocationID# 
		AND partnerID = #internalPartnerID#
		</cfquery>

		<cfquery datasource="startfly">
		DELETE FROM locationFacilities 
		WHERE locationID = #internalLocationID# 
		AND partnerID = #internalPartnerID#
		</cfquery>

		<cfif isDefined("arguments.facilities")>
			<cfloop index="i1" list="#structKeyList(arguments.facilities)#">
				
			<cfif arguments.facilities[i1]['selected'] is true >

				<cfset internalFacilityID = objTools.internalID('facilities',i1) />

				<cfquery datasource="startfly">
					INSERT INTO locationFacilities (
					partnerID,
					locationID,
					facility
					) VALUES (
					#internalPartnerID#,
					#locationID#,
					#internalFacilityID#
					)
				</cfquery>
			</cfif>


			</cfloop>
		</cfif>


		<cfset result['arguments'] = arguments />

		<cfset objTools.runtime('patch', '/partner/{partnerID}/locations/{locationID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

	<cffunction name="delete" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="locationID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery datasource="startfly">
		UPDATE locations 
		SET deleted = 1 
		WHERE sID = '#arguments.locationID#' 
		AND partnerID = #internalPartnerID#
		</cfquery>

		<cfset result['data']['locationID'] = arguments.locationID />

		<cfset objTools.runtime('delete', '/partner/{partnerID}/locations/{locationID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
