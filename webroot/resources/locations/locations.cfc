<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/locations" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="type" type="numeric" required="false" default="0" />

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
		AND locations.partnerID = #internalPartnerID# 
		AND locations.deleted = 0
		ORDER BY locations.name
		</cfquery>


		<cfset dataArray = arrayNew(1) />

		<cfif locations.recordCount gt 0>
			

			<cfloop query="locations">
				
				<cfset dataArray[locations.currentRow]['locationID'] = locations.sID />
				<cfset dataArray[locations.currentRow]['name'] = locations.name />
				<cfset dataArray[locations.currentRow]['address1'] = locations.add1 />
				<cfset dataArray[locations.currentRow]['address2'] = locations.add2 />
				<cfset dataArray[locations.currentRow]['address3'] = locations.add3 />
				<cfset dataArray[locations.currentRow]['town'] = locations.town />
				<cfset dataArray[locations.currentRow]['county'] = locations.county />
				<cfset dataArray[locations.currentRow]['country'] = locations.country />
				<cfset dataArray[locations.currentRow]['countryName'] = locations.countryName />
				<cfset dataArray[locations.currentRow]['postcode'] = locations.postcode />
				<cfset dataArray[locations.currentRow]['latitude'] = locations.latitude />
				<cfset dataArray[locations.currentRow]['longitude'] = locations.longitude />
				<cfset dataArray[locations.currentRow]['homeAddress'] = locations.homeAddress />
				<cfset dataArray[locations.currentRow]['hideAddress'] = locations.hideAddress />

				<cfquery name="facilities" datasource="startfly">
				SELECT facility 
				FROM locationFacilities 
				WHERE locationID = '#locations.ID#' 
				AND partnerID = #internalPartnerID#
				</cfquery>

				<cfset facilitiesArray = arrayNew(1) />
				<cfloop query="facilities">
					<cfset dataArray[locations.currentRow]['facilities'][facilities.facility]['selected'] = true />
				</cfloop>

				<cfset result['data']['facilities'] = facilitiesArray />


			</cfloop>


		<cfelse>

			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'No items' />

		</cfif>

		<cfset result['data'] = dataArray />


		<cfset objTools.runtime('get', '/partner/{partnerID}/locations', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset objAccum = createObject('component','/resources/private/accum') />
		<cfset locationID = objAccum.newID('secureIDPrefix') />
		<cfset sID = objTools.secureID() />

		<cfquery datasource="startfly">
		INSERT INTO locations (
		ID,
		sID,
		partnerID,
		name,
		add1,
		add2,
		add3,
		town,
		county,
		country,
		postcode,
		latitude,
		longitude,
		homeAddress,
		hideAddress,
		created
		) VALUES (
		#locationID#,
		'#sID#',
		#internalPartnerID#,
		'#arguments.name#',
		'#arguments.address1#',
		'#arguments.address2#',
		'#arguments.address3#',
		'#arguments.town#',
		'#arguments.county#',
		'#arguments.country#',
		'#arguments.postcode#',
		'#arguments.latitude#',
		'#arguments.longitude#',
		#arguments.homeAddress#,
		#arguments.hideAddress#,
		NOW()
		)
		</cfquery>


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



		<cfset result['data']['location']['locationID'] = sID />
		<cfset result['data']['location']['name'] = arguments.name />
		<cfset result['data']['location']['address1'] = arguments.address1 />
		<cfset result['data']['location']['address2'] = arguments.address2 />
		<cfset result['data']['location']['address3'] = arguments.address3 />
		<cfset result['data']['location']['town'] = arguments.town />
		<cfset result['data']['location']['county'] = arguments.county />
		<cfset result['data']['location']['country'] = arguments.country />
		<cfset result['data']['location']['postcode'] = arguments.postcode />
		<cfset result['data']['location']['latitude'] = arguments.latitude />
		<cfset result['data']['location']['longitude'] = arguments.longitude />
		<cfset result['data']['location']['homeAddress'] = arguments.homeAddress />
		<cfset result['data']['location']['hideAddress'] = arguments.hideAddress />
		<cfset result['data']['location']['facilities'] = arguments.facilities />


		<cfset objTools.runtime('post', '/partner/{partnerID}/locations', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
