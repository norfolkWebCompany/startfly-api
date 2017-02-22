<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/favourites/partners" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


			<cfquery name="q" datasource="startfly">
			SELECT 
			partner.*, 
			countries.name AS countryName  
			FROM favouritePartners  
			INNER JOIN partner ON favouritePartners.partnerID = partner.ID 
			LEFT JOIN countries ON partner.country = countries.ID 
			WHERE favouritePartners.customerID = #internalCustomerID# 
			ORDER BY favouritePartners.created DESC
			</cfquery>

			<cfset dataArray = arrayNew(1) />


			<cfloop query="q">
	
				<cfset dataArray[q.currentRow]['isFavourite'] = 1 />
				<cfset dataArray[q.currentRow]['ID'] = q.sID />
				<cfset dataArray[q.currentRow]['nickname'] = q.nickname />

				<cfset dataArray[q.currentRow]['ID'] = q.sID />
				<cfset dataArray[q.currentRow]['nickname'] = q.nickname />

				<cfif q.useBusinessName is 1>
					<cfset dataArray[q.currentRow]['name'] = q.company />
				<cfelse>					
					<cfset dataArray[q.currentRow]['name'] = q.firstname & ' ' & q.surname />
				</cfif>


				<cfset dataArray[q.currentRow]['company'] = q.company />
				<cfset dataArray[q.currentRow]['address1'] = q.add1 />
				<cfset dataArray[q.currentRow]['address2'] = q.add2 />
				<cfset dataArray[q.currentRow]['address3'] = q.add3 />
				<cfset dataArray[q.currentRow]['town'] = q.town />
				<cfset dataArray[q.currentRow]['county'] = q.county />
				<cfset dataArray[q.currentRow]['country'] = q.country />
				<cfset dataArray[q.currentRow]['countryName'] = q.countryName />
				<cfset dataArray[q.currentRow]['postcode'] = q.postcode />
				<cfset dataArray[q.currentRow]['gender'] = q.gender />
				<cfset dataArray[q.currentRow]['previewText'] = q.previewText />
				<cfset dataArray[q.currentRow]['bio'] = q.bio />

				<cfif q.avatar is ''>
					<cfset dataArray[q.currentRow]['avatar'] = 'https://beta.startfly.co.uk/assets/images/' & 'upload-icon.png' />
				<cfelse>
					<cfset dataArray[q.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/partner/' & q.avatar />
				</cfif>

				<cfset dataArray[q.currentRow]['webURL'] = q.webURL />
				<cfset dataArray[q.currentRow]['fbURL'] = q.fbURL />
				<cfset dataArray[q.currentRow]['twitterURL'] = q.twitterURL />
				<cfset dataArray[q.currentRow]['youtubeURL'] = q.youtubeURL />
				<cfset dataArray[q.currentRow]['promoURL'] = q.promoURL />
				<cfset dataArray[q.currentRow]['firstAid'] = q.firstAid />
				<cfset dataArray[q.currentRow]['created'] = objDates.toJSON(objDates.fromEpoch(q.created)) />


			</cfloop>

			<cfset result['data'] = dataArray />


			<cfset objTools.runtime('post', '/customer/{customerID}/favourites/partners', (getTickCount() - sTime) ) />


		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
