<cfcomponent extends="taffy.core.resource" taffy:uri="/reporting/customer/location" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="false" default="" />
		<cfargument name="customerID" type="string" required="false" default="" />
		<cfargument name="listingName" type="string" required="false" default="" />
		<cfargument name="location" type="string" required="false" default="" />
		<cfargument name="gender" type="string" required="false" default="" />
		<cfargument name="endYear" type="numeric" required="true" default="#year(now())#" />
		<cfargument name="endMonth" type="numeric" required="true" default="#month(now())#" />
		<cfargument name="startYear" type="numeric" required="true" default="#year(now())-1#" />
		<cfargument name="startMonth" type="numeric" required="true" default="#month(now())#" />

		<cfset objReporting = createObject('component','/resources/private/reporting') />
		<cfset objDates = createObject('component','/resources/private/dates') />
		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

        <cfif arguments.partnerID neq ''>
	        <cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />
        </cfif>
        <cfif arguments.customerID neq ''>
	        <cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />
        </cfif>
        <cfif arguments.location neq ''>
	        <cfset internalLocationID = objTools.internalID('locations',arguments.location) />
        </cfif>

		<cfset labels = arrayNew(1) />
		<cfset data = arrayNew(1) />
		<cfset series = arrayNew(1) />

		<cfset dateStruct = objReporting.dateStructure(arguments) />

		<cfquery name="listings" datasource="startfly">
		SELECT 
		COUNT(bookingDetail.customerID) AS total,
		listing.location,
		locations.name 
		FROM bookingDetail 
		INNER JOIN listing ON bookingDetail.listingID = listing.ID 
		LEFT JOIN locations ON listing.location = locations.ID
		WHERE bookingDetail.status IN (1,2,3,5)
		<cfif arguments.partnerID neq ''>
		AND bookingDetail.partnerID = #internalPartnerID# 
		</cfif>
		<cfif arguments.customerID neq ''>
		AND bookingDetail.customerID = #internalCustomerID# 
		</cfif>
		<cfif arguments.location neq ''>
		AND listing.location = #internalLocationID# 
		</cfif>
		<cfif arguments.listingName neq ''>
		AND listing.name LIKE '%#arguments.listingName#%' 
		</cfif> 
		GROUP BY locations.name
		ORDER BY locations.name
		</cfquery>

		<cfset reportData = arrayNew(1) />

		<cfloop query="listings">
			<cfset arrayAppend(reportData,listings.total) />
	
			<cfset labelName = listings.name />
			<cfset arrayAppend(labels,labelName) /> 

		</cfloop>

		<cfset result['data']['data'] = arrayNew(1) />

		<cfset result['data']['labels'] = labels />
		<cfset result['data']['data'] = reportData />
		<cfset result['data']['total'] = arraySum(listToArray(valueList(listings.total))) />

			<cfset objTools.runtime('post', '/reporting/customer/location', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
