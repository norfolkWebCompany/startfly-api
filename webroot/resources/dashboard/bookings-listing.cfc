<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/dashboard/bookings" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="endYear" type="numeric" required="true" default="#year(now())#" />
		<cfargument name="endMonth" type="numeric" required="true" default="#month(now())#" />
		<cfargument name="startYear" type="numeric" required="true" default="#year(now())#" />
		<cfargument name="startMonth" type="numeric" required="true" default="#month(now())-1#" />

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
		<cfset series = arrayNew(1) />

		<cfset grossData = arrayNew(1) />
		<cfset commissionData = arrayNew(1) />
		<cfset countData = arrayNew(1) />

		<cfloop index="y" from="#startYear#" to="#endYear#">

			<cfif y is startYear>
				<cfloop index="sm" from="#startMonth#" to="12">

					<cfquery name="q" datasource="startfly">
					SELECT 
					listing.name,
					listing.ID,
					IFNULL(count(bookings.gross), 0) AS total,
					IFNULL(sum(bookings.gross), 0) AS gross,
					IFNULL(sum(bookings.commission), 0) AS commission
					FROM bookings 
					INNER JOIN listing ON bookings.listingID = listing.ID
					WHERE month(bookings.created) = #numberFormat(sm,'00')#
					AND year(bookings.created) = #y# 
					AND bookings.partnerID = '#arguments.partnerID#'
					</cfquery>

					<cfset countData[arrayLen(countData) + 1] = q.total />
					<cfset grossData[arrayLen(grossData) + 1] = q.gross />
					<cfset commissionData[arrayLen(commissionData) + 1] = q.commission />

				</cfloop>

			<cfelseif y is endYear>
				<cfloop index="em" from="1" to="#endMonth#">

					<cfquery name="q" datasource="startfly">
					SELECT 
					listing.name,
					listing.ID,
					IFNULL(count(bookings.gross), 0) AS total,
					IFNULL(sum(bookings.gross), 0) AS gross,
					IFNULL(sum(bookings.commission), 0) AS commission
					FROM bookings 
					INNER JOIN listing ON bookings.listingID = listing.ID
					WHERE month(bookings.created) = #numberFormat(em,'00')#
					AND year(bookings.created) = #y#
					AND bookings.partnerID = '#arguments.partnerID#'
					</cfquery>

					<cfset countData[arrayLen(countData) + 1] = q.total />
					<cfset grossData[arrayLen(grossData) + 1] = q.gross />
					<cfset commissionData[arrayLen(commissionData) + 1] = q.commission />

				</cfloop>

			<cfelse>
				<cfloop index="mm" from="1" to="12">

					<cfquery name="q" datasource="startfly">
					SELECT 
					listing.name,
					listing.ID,
					IFNULL(count(bookings.gross), 0) AS total,
					IFNULL(sum(bookings.gross), 0) AS gross,
					IFNULL(sum(bookings.commission), 0) AS commission
					FROM bookings 
					INNER JOIN listing ON bookings.listingID = listing.ID
					WHERE month(bookings.created) = #numberFormat(mm,'00')#
					AND year(bookings.created) = #y#
					AND bookings.partnerID = '#arguments.partnerID#'
					</cfquery>

					<cfset countData[arrayLen(countData) + 1] = q.total />
					<cfset grossData[arrayLen(grossData) + 1] = q.gross />
					<cfset commissionData[arrayLen(commissionData) + 1] = q.commission />

				</cfloop>
			</cfif>


		</cfloop>

		<cfquery name="q" datasource="startfly">
		SELECT 
		listing.name,
		listing.ID
		FROM bookings 
		INNER JOIN listing ON bookings.listingID = listing.ID
		WHERE month(bookings.created) = #numberFormat(month(now()),'00')#
		AND year(bookings.created) = #year(now())#
		AND bookings.partnerID = '#arguments.partnerID#'
		GROUP BY listing.name
		ORDER BY listing.name 
		</cfquery>

		<cfloop query="q">
				<cfset labels[arrayLen(labels) + 1] = q.name /> 
		</cfloop>



		<cfset result['data']['labels'] = labels />
		<cfset result['data']['data'] = arrayNew(1) />
		<cfset arrayAppend(result['data']['data'],grossData) />

		<cfset result['data']['totalsPeriod']['value'] = arraySum(grossData) />
		<cfset result['data']['totalsPeriod']['commission'] = arraySum(commissionData) />
		<cfset result['data']['totalsPeriod']['count'] = arraySum(countData) />

		<cfquery name="qYear" datasource="startfly">
		SELECT 
		IFNULL(count(bookings.gross), 0) AS total,
		IFNULL(sum(bookings.gross), 0) AS gross,
		IFNULL(sum(bookings.commission), 0) AS commission
		FROM bookings 
		WHERE year(bookings.created) = #year(now())#
		AND bookings.partnerID = '#arguments.partnerID#'
		</cfquery>

		<cfquery name="qMonth" datasource="startfly">
		SELECT 
		IFNULL(count(bookings.gross), 0) AS total,
		IFNULL(sum(bookings.gross), 0) AS gross,
		IFNULL(sum(bookings.commission), 0) AS commission
		FROM bookings 
		WHERE year(bookings.created) = #year(now())# 
		AND month(bookings.created) = #month(now())#
		AND bookings.partnerID = '#arguments.partnerID#'
		</cfquery>


		<cfset result['data']['totalsYear']['value'] = qYear.gross />
		<cfset result['data']['totalsYear']['commission'] = qYear.commission />
		<cfset result['data']['totalsYear']['count'] = qYear.total />
		<cfset result['data']['totalsMonth']['value'] = qMonth.gross />
		<cfset result['data']['totalsMonth']['commission'] = qMonth.commission />
		<cfset result['data']['totalsMonth']['count'] = qMonth.total />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
