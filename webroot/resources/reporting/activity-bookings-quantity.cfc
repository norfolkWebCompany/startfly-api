<cfcomponent extends="taffy.core.resource" taffy:uri="/reporting/activity/bookings/quantity" hint="some hint about this resource">
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

		<cfset rData = arrayNew(1) />

		<cfloop index="s1" list="#listSort(structKeyList(dateStruct),'numeric')#">

			<cfquery name="q" datasource="startfly">
			SELECT 
			IFNULL(count(*), 0) AS total
			FROM bookingDetail 
			LEFT JOIN listing ON bookingDetail.listingID = listing.ID
			WHERE month(bookingDetail.created) = #numberFormat(dateStruct[s1]['month'],'00')#
			AND year(bookingDetail.created) = #dateStruct[s1]['year']# 
			AND bookingDetail.status IN (1,2,3,5)
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
			</cfquery>

			<cfset arrayAppend(rData,q.total) />

			<cfset labelName = left(monthAsString(numberFormat(dateStruct[s1]['month'],'00')),3) & ' ' &  dateStruct[s1]['year'] />
			<cfset arrayAppend(labels,labelName) /> 

		</cfloop>

		<cfset series[1] = 'Value' />

		<cfset result['data']['labels'] = labels />
		<cfset result['data']['data'] = arrayNew(1) />
		<cfset result['data']['data'] = rData />
		<cfset result['data']['series'] = series />

			<cfset objTools.runtime('post', '/reporting/activity/bookings/quantity', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
