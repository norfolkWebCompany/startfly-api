<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/profile/{id}" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">
		<cfargument name="id" type="string" required="true" />

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="q" datasource="startfly">
			SELECT 
			partner.sID,
			partner.firstname,
			partner.surname,
			partner.nickname,
			partner.company,
			partner.locationID,
			partner.landline,
			partner.mobile,
			partner.email,
			partner.gender,
			partner.niNumber,
			partner.previewText,
			partner.bio,
			partner.avatar,
			partner.webURL,
			partner.fbURL,
			partner.twitterURL,
			partner.instagramURL,
			partner.youtubeURL,
			partner.promoURL,
			partner.dbs,
			partner.businessInsurance,
			partner.vatRegistered,
			partner.yearEndDay,
			partner.yearEndMonth,
			partner.useBusinessName,
			partner.created,
			partner.dob,
			partner.dobBusiness,
			partner.firstAid,
			locations.sID AS locationSID,
			locations.add1,
			locations.add2,
			locations.add3,
			locations.town,
			locations.county,
			locations.country,
			locations.postcode,
			locations.latitude,
			locations.longitude,
			countries.name AS countryName  
			FROM partner 
			LEFT JOIN locations ON partner.locationID = locations.ID 
			LEFT JOIN countries ON partner.country = countries.ID
			WHERE partner.sID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" />
		</cfquery>


			<cfif q.recordCount gt 0>
	
				<cfset result['data']['ID'] = q.sID />
				<cfset result['data']['firstname'] = q.firstname />
				<cfset result['data']['surname'] = q.surname />
				<cfset result['data']['nickname'] = q.nickname />
				<cfset result['data']['company'] = q.company />
				<cfset result['data']['landline'] = q.landline />
				<cfset result['data']['mobile'] = q.mobile />
				<cfset result['data']['email'] = q.email />
				<cfset result['data']['gender'] = q.gender />
				<cfset result['data']['niNumber'] = q.niNumber />
				<cfset result['data']['previewText'] = q.previewText />
				<cfset result['data']['bio'] = q.bio />

				<cfset result['data']['location']['locationID'] = q.locationSID />
				<cfset result['data']['location']['address1'] = q.add1 />
				<cfset result['data']['location']['address2'] = q.add2 />
				<cfset result['data']['location']['address3'] = q.add3 />
				<cfset result['data']['location']['town'] = q.town />
				<cfset result['data']['location']['county'] = q.county />
				<cfset result['data']['location']['country'] = q.country />
				<cfset result['data']['location']['countryName'] = q.countryName />
				<cfset result['data']['location']['postcode'] = q.postcode />
				<cfset result['data']['location']['latitude'] = q.latitude />
				<cfset result['data']['location']['longitude'] = q.longitude />


				<cfif q.avatar is ''>
					<cfset result['data']['avatar'] = 'https://beta.startfly.co.uk/assets/images/' & 'upload-icon.png' />
				<cfelse>
					<cfset result['data']['avatar'] = 'https://beta.startfly.co.uk/images/partner/' & q.avatar />
				</cfif>

				<cfif 
					q.webURL neq '' OR 
					q.fbURL neq '' OR 
					q.twitterURL neq '' OR 
					q.youtubeURL neq '' OR 
					q.instagramURL neq ''>
						
					<cfset result['data']['hasSocial'] = 1 />
				<cfelse>
					<cfset result['data']['hasSocial'] = 0 />
				</cfif>

				<cfset result['data']['webURL'] = q.webURL />
				<cfset result['data']['fbURL'] = q.fbURL />
				<cfset result['data']['twitterURL'] = q.twitterURL />
				<cfset result['data']['youtubeURL'] = q.youtubeURL />
				<cfset result['data']['instagramURL'] = q.instagramURL />
				<cfset result['data']['promoURL'] = q.promoURL />
				<cfset result['data']['firstAid'] = q.firstAid />
				<cfset result['data']['dbs'] = q.dbs />
				<cfset result['data']['businessInsurance'] = q.businessInsurance />
				<cfset result['data']['yearEndDay'] = q.yearEndDay />
				<cfset result['data']['yearEndMonth'] = q.yearEndMonth />
				<cfset result['data']['useBusinessName'] = q.useBusinessName />
				<cfset result['data']['vatRegistered'] = q.vatRegistered />

				<cfset result['data']['created'] = objDates.fromEpoch(q.created,'JSON') /> />
				<cfif q.dob neq 0>
					<cfset result['data']['dob'] = objDates.fromEpoch(q.dob,'JSON') />
				<cfelse>
					<cfset result['data']['dob'] = '' />
				</cfif>

				<cfif q.dobBusiness neq 0>
					<cfset result['data']['dobBusiness'] = objDates.fromEpoch(q.dobBusiness,'JSON') />
				<cfelse>
					<cfset result['data']['dobBusiness'] = '' />
				</cfif>
				<cfif q.dob neq 0>
					<cfset result['data']['age'] = ceiling(( ( objDates.toEpoch(now()) - q.dob ) / 31556926 )) />
				<cfelse>
					<cfset result['data']['age'] = '' />
				</cfif>


				<cfset result['data']['courses'] = arrayNew(1) />


			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>

			<cfset objTools.runtime('get', '/partner/profile/{id}', (getTickCount() - sTime) ) />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>



	<cffunction name="post" access="public" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfargument name="firstname" type="string" required="true" />
		<cfargument name="surname" type="string" required="true" />

		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset dob = objDates.toCF(arguments.dob,'JSON','/') />
		<cfset dob = objDates.toEpoch(dob) />

		<cfset dobBusiness = objDates.toCF(arguments.dobBusiness,'JSON','/') />
		<cfset dobBusiness = objDates.toEpoch(dobBusiness) />

		<cfset updated = objDates.toEpoch(now()) />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.ID) />

		<cfquery datasource="startfly">
		UPDATE partner SET 
		firstname = '#arguments.firstName#',
		surname = '#arguments.surname#', 
		nickname = '#arguments.nickname#',
		company = '#arguments.company#',
		landline = '#arguments.landline#',
		mobile = '#arguments.mobile#',
		gender = '#arguments.gender#',
		niNumber = '#arguments.niNumber#',
		previewText = '#arguments.previewText#',
		bio = '#arguments.bio#',
		dob = #dob#,
		dobBusiness = #dobBusiness#,
		updated = #updated#,
		webURL = '#arguments.webURL#',
		fbURL = '#arguments.fbURL#',
		twitterURL = '#arguments.twitterURL#',
		youtubeURL = '#arguments.youtubeURL#',
		promoURL = '#arguments.promoURL#',
		firstAid = #arguments.firstAid#,
		dbs = #arguments.dbs#,
		businessInsurance = #arguments.businessInsurance#,
		yearEndDay = #arguments.yearEndDay#,
		yearEndMonth = #arguments.yearEndMonth#,
		useBusinessName = #arguments.useBusinessName#,
		vatRegistered = #arguments.vatRegistered#
		WHERE ID = #internalPartnerID#
		</cfquery>

		<cfif arguments.addressChange is 1>
			<cfif arguments.addressIsNew is 1>

				<cfset objAccum = createObject('component','/resources/private/accum') />
				
				<cfset newLocationID = objAccum.newID('secureIDPrefix') />
				<cfset locationSID = objTools.secureID() />

				<cfquery datasource="startfly">
				INSERT INTO locations (
				ID,
				sID,
				partnerID,
				add1,
				add2,
				add3,
				town,
				county,
				country,
				postCode,
				latitude,
				longitude,
				created
				) VALUES (
				#newLocationID#,
				'#locationSID#',
				#internalPartnerID#,
				'#arguments.location.address1#',
				'#arguments.location.address2#',
				'#arguments.location.address3#',
				'#arguments.location.town#',
				'#arguments.location.county#',
				'#arguments.location.country#',
				'#arguments.location.postCode#',
				#arguments.location.latitude#,
				#arguments.location.longitude#, 
				NOW()
				)
				</cfquery>

				<cfquery datasource="startfly">
				UPDATE partner SET 
				locationID = #newLocationID# 
				WHERE ID = #internalPartnerID#
				</cfquery> 

			<cfelse>
				<cfquery datasource="startfly">
				UPDATE locations SET 
				add1 = '#arguments.location.address1#',
				add2 = '#arguments.location.address2#',
				add3 = '#arguments.location.address3#',
				town = '#arguments.location.town#',
				county = '#arguments.location.county#',
				country = '#arguments.location.country#',
				postCode = '#arguments.location.postCode#',
				latitude = #arguments.location.latitude#,
				longitude = #arguments.location.longitude# 
				WHERE locations.sID = '#arguments.location.locationID#'
				</cfquery>
			</cfif>
		</cfif>

		<cfset objTools.runtime('post', '/partner/profile/{id}', (getTickCount() - sTime) ) />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
