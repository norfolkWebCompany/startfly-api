<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/reporting/listing/capacity" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="endYear" type="numeric" required="true" default="#year(now())#" />
		<cfargument name="endMonth" type="numeric" required="true" default="#month(now())#" />
		<cfargument name="startYear" type="numeric" required="true" default="#year(now())-1#" />
		<cfargument name="startMonth" type="numeric" required="true" default="#month(now())#" />

		<cfset objReporting = createObject('component','/resources/private/reporting') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset labels = arrayNew(1) />
		<cfset data = arrayNew(1) />
		<cfset series = arrayNew(1) />

		<cfset dateStruct = objReporting.dateStructure(arguments) />

		<cfquery name="listings" datasource="startfly">
		SELECT 
		listing.ID,
		listing.name 
		FROM listing 
		WHERE partnerID = '#arguments.partnerID#' 
		AND deleted = 0
		ORDER BY listing.name
		</cfquery>

		<cfset reportData = arrayNew(1) />

		<cfloop query="listings">

			<cfset rData = arrayNew(1) />
	
			<cfloop index="s1" list="#listSort(structKeyList(dateStruct),'numeric')#">

				<cfquery name="q" datasource="startfly">
				SELECT 
				IFNULL(sum(listingAttendance.views), 0) AS total
				FROM listingAttendance 
				WHERE epMonth = #numberFormat(dateStruct[s1]['month'],'00')#
				AND epYear = #dateStruct[s1]['year']#
				AND listingAttendance.partnerID = '#arguments.partnerID#' 
				AND listingAttendance.listingID = '#listings.ID#'
				</cfquery>

				<cfset arrayAppend(rData,q.total) />

				<cfif listings.currentRow is 1>
					<cfset labelName = left(monthAsString(numberFormat(dateStruct[s1]['month'],'00')),3) & ' ' &  dateStruct[s1]['year'] />
					<cfset arrayAppend(labels,labelName) /> 
				</cfif>

			</cfloop>

			<cfset arrayAppend(series,listings.name) />
			<cfset arrayAppend(reportData,rData) />

		</cfloop>

		<cfset result['data']['labels'] = labels />
		<cfset result['data']['data'] = arrayNew(1) />
		<cfset result['data']['data'] = reportData />
		<cfset result['data']['series'] = series />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
