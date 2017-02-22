<cfcomponent extends="taffy.core.resource" taffy:uri="/public/partner/favourite" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset result['data']['added'] = 0 />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

		<cfquery name="fCheck" datasource="startfly">
		SELECT ID FROM 
		favouritePartners 
		WHERE partnerID = #internalPartnerID# 
		AND customerID = #internalCustomerID# 
		</cfquery>

		<cfif fCheck.recordCount is 0>
			<cfquery datasource="startfly">
			INSERT INTO favouritePartners (
			customerID,
			partnerID,
			created
			) VALUES (
			#internalCustomerID#,
			#internalPartnerID#,
			NOW()
			)
			</cfquery>

			<cfset result['data']['added'] = 1 />

		<cfelse>
			<cfquery name="fCheck" datasource="startfly">
			DELETE FROM	favouritePartners 
			WHERE partnerID = #internalPartnerID# 
			AND customerID = #internalCustomerID# 
			</cfquery>
		</cfif>


		<cfset objTools.runtime('post', '/public/partner/favourite', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
