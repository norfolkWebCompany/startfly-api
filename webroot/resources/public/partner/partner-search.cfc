<cfcomponent extends="taffy.core.resource" taffy:uri="/public/partner/search" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="customerID" type="string" required="false" default="">


		<cfset showTestContent = 0 />

		<cfquery name="customer" datasource="startfly">
		SELECT showTestContent 
		FROM customer 
		WHERE sID = '#arguments.customerID#' 
		LIMIT 1
		</cfquery>

		<cfif customer.recordCount is 1>
			<cfset showTestContent = customer.showTestContent />
		</cfif>


		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="totalRecords" datasource="startfly">
		SELECT COUNT(*) AS totalRecs
		FROM partner 
		LEFT JOIN countries ON partner.country = countries.ID 
		LEFT JOIN locations ON partner.locationID = locations.ID 
		WHERE partner.status = 1 
		AND partner.activated = 1 
		<cfif showTestContent is 0>
		AND partner.isTest = 0
		</cfif>
        <cfif isDefined("arguments.name") and arguments.name neq ''>
        AND CONCAT(partner.firstname,' ',partner.surname,partner.nickname,partner.company) LIKE '%#arguments.name#%' 
        </cfif>
        <cfif arguments.address neq ''>
        AND 3963 * (ACOS((SIN(#arguments.position[1]#/57.2958) * SIN(locations.latitude/57.2958)) + (COS(#arguments.position[1]#/57.2958) * COS(locations.latitude/57.2958) * COS(locations.longitude/57.2958 - #arguments.position[2]#/57.2958)))) <= #arguments.distance#
        </cfif>
		</cfquery>

		<cfset result['pagination']['totalRecords'] = totalRecords.totalRecs />
		<cfset result['pagination']['pages'] = ceiling(totalRecords.totalRecs / arguments.pagination.limit) />


		<cfquery name="partners" datasource="startfly">
			SELECT 
			partner.sID,
			partner.nickname,
			partner.firstname,
			partner.surname,
			partner.company,
			partner.useBusinessName,
			partner.gender,
			partner.previewText,
			partner.bio,
			partner.avatar,
			partner.webURL,
			partner.fbURL,
			partner.twitterURL,
			partner.youtubeURL,
			partner.promoURL,
			partner.firstAid,
			partner.created,
			locations.name AS locationName,
			locations.longitude,
			locations.latitude,
			locations.town,
			locations.county,
			locations.hideAddress,
			3963 * (ACOS((SIN(#arguments.position[1]#/57.2958) * SIN(locations.latitude/57.2958)) + (COS(#arguments.position[1]#/57.2958) * COS(locations.latitude/57.2958) * COS(locations.longitude/57.2958 - #arguments.position[2]#/57.2958)))) AS distance,
			countries.name AS countryName,  
			(
				SELECT 
				IFNULL( ( SUM(reviews.rating) / COUNT(*) ),0) 
				FROM reviews 
				WHERE type = 'partner' 
				AND partnerID = partner.ID 
			) AS ratingAvg   
			FROM partner 
			LEFT JOIN countries ON partner.country = countries.ID 
			LEFT JOIN locations ON partner.locationID = locations.ID 
			WHERE partner.status = 1 
			AND partner.activated = 1
			<cfif showTestContent is 0>
			AND partner.isTest = 0
			</cfif>
	        <cfif isDefined("arguments.name") and arguments.name neq ''>
	        AND CONCAT(partner.firstname,' ',partner.surname,partner.nickname,partner.company) LIKE '%#arguments.name#%' 
	        </cfif>
	        <cfif arguments.address neq ''>
	        AND 3963 * (ACOS((SIN(#arguments.position[1]#/57.2958) * SIN(locations.latitude/57.2958)) + (COS(#arguments.position[1]#/57.2958) * COS(locations.latitude/57.2958) * COS(locations.longitude/57.2958 - #arguments.position[2]#/57.2958)))) <= #arguments.distance#
	        </cfif>
			ORDER BY #arguments.orderBy.sortField# 
			<cfif arguments.orderBy.doReverse> 
			DESC
			</cfif>
			LIMIT #((arguments.pagination.currentPage * arguments.pagination.limit)-arguments.pagination.limit)#, #arguments.pagination.limit#
		</cfquery>

		<cfset dataArray = arrayNew(1) />
		<cfset mapArray = arrayNew(1) />

		<cfloop query="partners">
			
				<cfset dataArray[partners.currentRow]['ID'] = partners.sID />
				<cfset dataArray[partners.currentRow]['nickname'] = partners.nickname />

				<cfif partners.useBusinessName is 1>
					<cfset dataArray[partners.currentRow]['name'] = partners.company />
				<cfelse>					
					<cfset dataArray[partners.currentRow]['name'] = partners.firstname & ' ' & partners.surname />
				</cfif>

				<cfset dataArray[partners.currentRow]['town'] = partners.town />
				<cfset dataArray[partners.currentRow]['county'] = partners.county />
				<cfset dataArray[partners.currentRow]['gender'] = partners.gender />
				<cfset dataArray[partners.currentRow]['previewText'] = partners.previewText />
				<cfset dataArray[partners.currentRow]['bio'] = partners.bio />
				<cfset dataArray[partners.currentRow]['rating'] = partners.ratingAvg />

				<cfif partners.avatar is ''>
					<cfset dataArray[partners.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/profile-avatar.png' />
				<cfelse>
					<cfset dataArray[partners.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/partner/' & partners.avatar />
				</cfif>

				<cfset dataArray[partners.currentRow]['webURL'] = partners.webURL />
				<cfset dataArray[partners.currentRow]['fbURL'] = partners.fbURL />
				<cfset dataArray[partners.currentRow]['twitterURL'] = partners.twitterURL />
				<cfset dataArray[partners.currentRow]['youtubeURL'] = partners.youtubeURL />
				<cfset dataArray[partners.currentRow]['promoURL'] = partners.promoURL />
				<cfset dataArray[partners.currentRow]['firstAid'] = partners.firstAid />
				<cfset dataArray[partners.currentRow]['useBusinessName'] = partners.useBusinessName />


				<cfset dataArray[partners.currentRow]['created'] = objDates.toJSON(objDates.fromEpoch(partners.created)) />

				<cfif partners.longitude neq '' and partners.latitude neq ''>
					<cfset mapArrayLen = arrayLen(mapArray)+1 />
					<cfset mapArray[mapArrayLen]['longitude'] = partners.longitude />
					<cfset mapArray[mapArrayLen]['latitude'] = partners.latitude />
					<cfset mapArray[mapArrayLen]['markerPosition'] = partners.latitude & ',' & partners.longitude />
				</cfif>


		</cfloop>

			<cfset result['data']['partners'] = dataArray />
			<cfset result['data']['mapData'] = mapArray />

			<cfset result['arguments'] = arguments />

			<cfset objTools.runtime('post', '/public/partner/search', (getTickCount() - sTime) ) />

	<cfreturn representationOf(result).withStatus(200) />
</cffunction>

</cfcomponent>
