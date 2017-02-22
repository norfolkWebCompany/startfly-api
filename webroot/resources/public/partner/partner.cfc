<cfcomponent extends="taffy.core.resource" taffy:uri="/public/partner/{id}" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="id" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />
		<cfset objDates = createObject('component','/resources/private/dates') />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="q" datasource="startfly">
			SELECT 
			partner.*, 
			countries.name AS countryName  
			FROM partner 
			LEFT JOIN countries ON partner.country = countries.ID
			WHERE nickname = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" /> 
			LIMIT 1
		</cfquery>

		<cfif q.recordCount is 0>
			<cfquery name="q" datasource="startfly">
				SELECT 
				partner.*, 
				countries.name AS countryName  
				FROM partner 
				LEFT JOIN countries ON partner.country = countries.ID
				WHERE sID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" /> 
				LIMIT 1
			</cfquery>
		</cfif>



			<cfif q.recordCount gt 0>
	
				<cfset result['data']['ID'] = q.sID />
				<cfset result['data']['firstname'] = q.firstname />
				<cfset result['data']['surname'] = q.surname />
				<cfset result['data']['nickname'] = q.nickname />
				<cfset result['data']['company'] = q.company />
				<cfset result['data']['town'] = q.town />
				<cfset result['data']['county'] = q.county />
				<cfset result['data']['country'] = q.country />
				<cfset result['data']['previewText'] = q.previewText />
				<cfset result['data']['bio'] = q.bio />


				<cfswitch expression="#q.gender#">
					<cfcase value="M">
						<cfset result['data']['gender'] = 'Male' />
					</cfcase>
					<cfcase value="F">
						<cfset result['data']['gender'] = 'Female' />
					</cfcase>
					<cfdefaultcase>
						<cfset result['data']['gender'] = 'Not Set' />
					</cfdefaultcase>
				</cfswitch>

				<cfset result['data']['businessInsurance'] = q.businessInsurance />

				<cfset result['data']['firstAid'] = q.firstAid />

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

				<cfset safeWebURL = q.webURL />
				<cfif not listContains(q.webURL,'http://') and  not listContains(q.webURL,'https://')>
					<cfset safeWebURL = 'http://' & q.webURL />					
				</cfif>

				<cfset result['data']['webURL'] = safeWebURL />

				<cfset safeFBURL = q.fbURL />
				<cfif not listContains(q.fbURL,'http://') and not listContains(q.fbURL,'https://')>
					<cfset safeFBURL = 'https://www.facebook.com/' & q.fbURL />					
				</cfif>


				<cfset result['data']['fbURL'] = safeFBURL />

				<cfset safeTwitterURL = q.twitterURL />
				<cfif not listContains(q.twitterURL,'http://') and not listContains(q.twitterURL,'https://')>
					<cfset safeTwitterURL = 'https://twitter.com/' & q.twitterURL />					
				</cfif>


				<cfset result['data']['twitterURL'] = safeTwitterURL />
				<cfset result['data']['instagramURL'] = q.instagramURL />
				<cfset result['data']['youtubeURL'] = q.youtubeURL />
				<cfset result['data']['promoURL'] = q.promoURL />
				<cfset result['data']['firstAid'] = q.firstAid />
				<cfset result['data']['useBusinessName'] = q.useBusinessName />
				<cfset result['data']['vatRegistered'] = q.vatRegistered />


				<cfset result['data']['age'] = dateDiff("yyyy",objDates.fromEpoch(q.dob), now()) />

				<cfset result['data']['created'] = objDates.toJSON(objDates.fromEpoch(q.created)) />
	

			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>

			<cfset objTools.runtime('post', '/public/partner/{id}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>



	<cffunction name="post" access="public" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfargument name="firstname" type="string" required="true" />
		<cfargument name="surname" type="string" required="true" />
		<cfargument name="address1" type="string" required="true" />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfset dobDay = listGetAt(arguments.dob,1,'/') />
		<cfset dobMonth = listGetAt(arguments.dob,2,'/') />
		<cfset dobYear = listGetAt(arguments.dob,3,'/') />

		<cfset thisDob = createDate(dobYear,dobMonth,dobDay) />

		<cfquery datasource="startfly">
		UPDATE partner SET 
		firstname = '#arguments.firstName#',
		surname = '#arguments.surname#', 
		nickname = '#arguments.nickname#',
		company = '#arguments.company#',
		add1 = '#arguments.address1#',
		add2 = '#arguments.address2#',
		add3 = '#arguments.address3#',
		town = '#arguments.town#',
		county = '#arguments.county#',
		postcode = '#arguments.postcode#',
		landline = '#arguments.landline#',
		mobile = '#arguments.mobile#',
		gender = '#arguments.gender#',
		niNumber = '#arguments.niNumber#',
		previewText = '#arguments.previewText#',
		bio = '#arguments.bio#',
		dob = #thisDob#,
		webURL = '#arguments.webURL#',
		fbURL = '#arguments.fbURL#',
		twitterURL = '#arguments.twitterURL#',
		youtubeURL = '#arguments.youtubeURL#',
		firstAid = #arguments.firstAid#,
		publicLi = #arguments.publicLi#,
		productLi = #arguments.productLi#,
		employerLi = #arguments.employerLi#,
		yearEndDay = #arguments.yearEndDay#,
		yearEndMonth = #arguments.yearEndMonth#,
		useBusinessName = #arguments.useBusinessName#,
		vatRegistered = #arguments.vatRegistered#
		WHERE ID = '#arguments.id#'
		</cfquery>


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
