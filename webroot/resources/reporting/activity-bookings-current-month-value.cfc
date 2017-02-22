<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/reporting/activity/bookings/currentMonth/value" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="endYear" type="numeric" required="true" default="#year(now())#" />
		<cfargument name="endMonth" type="numeric" required="true" default="#month(now())#" />
		<cfargument name="startYear" type="numeric" required="true" default="#year(now())-1#" />
		<cfargument name="startMonth" type="numeric" required="true" default="#month(now())#" />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset startYear = arguments.startYear />
		<cfset startMonth = arguments.startMonth />

		<cfset endYear = arguments.endYear />
		<cfset endMonth = arguments.endMonth />


		<cfset labels = arrayNew(1) />
		<cfset data = arrayNew(1) />
		<cfset reportData = arrayNew(1) />


		<cfquery name="eM" datasource="startfly">
		SELECT 
		epMonths.mth,
		epMonths.yr 
		FROM epMonths 
		WHERE epMonths.mth = 10 
		ORDER BY epMonths.ID
		</cfquery>


		<cfloop query="eM">
			<cfquery name="q" datasource="startfly">
			SELECT 
			IFNULL(sum(bookings.gross), 0) AS total
			FROM bookings 
			WHERE epMonth = #numberFormat(eM.mth,'00')#
			AND bookings.partnerID = '#arguments.partnerID#' 
			</cfquery>
			
			<cfset labels[arrayLen(labels) + 1] = left(monthAsString(eM.mth),3) & ' ' &  em.yr /> 

			<cfset reportData[arrayLen(reportData) + 1] = q.total />

		</cfloop>

		<cfset series[1] = 'Value' />

		<cfset result['data']['labels'] = labels />
		<cfset result['data']['data'] = arrayNew(1) />
		<cfset result['data']['data'] = reportData />
		<cfset result['data']['series'] = series />


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
