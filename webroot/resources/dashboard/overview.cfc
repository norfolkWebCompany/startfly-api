<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/dashboard/overview" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

<!--- revenue --->
		<cfquery name="qYear" datasource="startfly">
		SELECT 
		IFNULL(count(bookings.gross), 0) AS total,
		IFNULL(sum(bookings.gross), 0) AS gross,
		IFNULL(sum(bookings.commission), 0) AS commission
		FROM bookings 
		WHERE year(bookings.created) = #year(now())#
		AND bookings.partnerID = #internalPartnerID#
		</cfquery>

		<cfquery name="qMonth" datasource="startfly">
		SELECT 
		IFNULL(count(bookings.gross), 0) AS total,
		IFNULL(sum(bookings.gross), 0) AS gross,
		IFNULL(sum(bookings.commission), 0) AS commission
		FROM bookings 
		WHERE year(bookings.created) = #year(now())# 
		AND month(bookings.created) = #month(now())#
		AND bookings.partnerID = #internalPartnerID#
		</cfquery>


		<cfset result['data']['revenue']['totalsYear']['value'] = qYear.gross />
		<cfset result['data']['revenue']['totalsYear']['commission'] = qYear.commission />
		<cfset result['data']['revenue']['totalsYear']['count'] = qYear.total />
		<cfset result['data']['revenue']['totalsMonth']['value'] = qMonth.gross />
		<cfset result['data']['revenue']['totalsMonth']['commission'] = qMonth.commission />
		<cfset result['data']['revenue']['totalsMonth']['count'] = qMonth.total />

<!--- bookings accepted --->
		<cfquery name="qYear" datasource="startfly">
		SELECT 
		IFNULL(count(bookings.gross), 0) AS total,
		IFNULL(sum(bookings.gross), 0) AS gross,
		IFNULL(sum(bookings.commission), 0) AS commission
		FROM bookings 
		WHERE year(bookings.created) = #year(now())#
		AND bookings.partnerID = #internalPartnerID# 
		AND status = 1
		</cfquery>

		<cfquery name="qMonth" datasource="startfly">
		SELECT 
		IFNULL(count(bookings.gross), 0) AS total,
		IFNULL(sum(bookings.gross), 0) AS gross,
		IFNULL(sum(bookings.commission), 0) AS commission
		FROM bookings 
		WHERE year(bookings.created) = #year(now())# 
		AND month(bookings.created) = #month(now())#
		AND bookings.partnerID = #internalPartnerID#
		AND status = 1
		</cfquery>


		<cfset result['data']['bookingsAccepted']['totalsYear']['value'] = qYear.gross />
		<cfset result['data']['bookingsAccepted']['totalsYear']['commission'] = qYear.commission />
		<cfset result['data']['bookingsAccepted']['totalsYear']['count'] = qYear.total />
		<cfset result['data']['bookingsAccepted']['totalsMonth']['value'] = qMonth.gross />
		<cfset result['data']['bookingsAccepted']['totalsMonth']['commission'] = qMonth.commission />
		<cfset result['data']['bookingsAccepted']['totalsMonth']['count'] = qMonth.total />


<!--- bookings declined --->
		<cfquery name="qYear" datasource="startfly">
		SELECT 
		IFNULL(count(bookings.gross), 0) AS total,
		IFNULL(sum(bookings.gross), 0) AS gross,
		IFNULL(sum(bookings.commission), 0) AS commission
		FROM bookings 
		WHERE year(bookings.created) = #year(now())#
		AND bookings.partnerID = #internalPartnerID# 
		AND status = 2
		</cfquery>

		<cfquery name="qMonth" datasource="startfly">
		SELECT 
		IFNULL(count(bookings.gross), 0) AS total,
		IFNULL(sum(bookings.gross), 0) AS gross,
		IFNULL(sum(bookings.commission), 0) AS commission
		FROM bookings 
		WHERE year(bookings.created) = #year(now())# 
		AND month(bookings.created) = #month(now())#
		AND bookings.partnerID = #internalPartnerID#
		AND status = 2
		</cfquery>


		<cfset result['data']['bookingsDeclined']['totalsYear']['value'] = qYear.gross />
		<cfset result['data']['bookingsDeclined']['totalsYear']['commission'] = qYear.commission />
		<cfset result['data']['bookingsDeclined']['totalsYear']['count'] = qYear.total />
		<cfset result['data']['bookingsDeclined']['totalsMonth']['value'] = qMonth.gross />
		<cfset result['data']['bookingsDeclined']['totalsMonth']['commission'] = qMonth.commission />
		<cfset result['data']['bookingsDeclined']['totalsMonth']['count'] = qMonth.total />


<!--- customers --->
		<cfquery name="registered" datasource="startfly">
		SELECT 
		IFNULL(count(*), 0) AS total
		FROM partnerCustomers  
		WHERE partnerID = #internalPartnerID# 
		</cfquery>

		<cfquery name="registeredThisMonth" datasource="startfly">
		SELECT 
		IFNULL(count(*), 0) AS total
		FROM dimDate 
		INNER JOIN partnerCustomers ON dimDate.dateID = partnerCustomers.dateID 
		WHERE partnerCustomers.partnerID = #internalPartnerID# 
		AND dimDate.monthNumber = month(now())
		AND dimDate.year = year(now()) 
		</cfquery>


		<cfset result['data']['customers']['registered'] = registered.total />
		<cfset result['data']['customers']['registeredThisMonth'] = registeredThisMonth.total />

<!--- ratings --->
		<cfquery name="ratings" datasource="startfly">
		SELECT 
		IFNULL(avg(rating), 0) AS total
		FROM reviews  
		WHERE partnerID = #internalPartnerID# 
		AND type = 'listing'
		</cfquery>

		<cfquery name="ratingsThisMonth" datasource="startfly">
		SELECT 
		IFNULL(avg(rating), 0) AS total
		FROM reviews  
		WHERE partnerID = #internalPartnerID# 
		AND type = 'listing'
		AND year(reviews.created) = year(now()) 
		AND month(reviews.created) = month(now())
		</cfquery>


		<cfset result['data']['ratings']['total'] = ratings.total />
		<cfset result['data']['ratings']['thisMonth'] = ratingsThisMonth.total />

		<cfquery name="q" datasource="startfly">
		SELECT 
		IFNULL(sum(partnerViews.views), 0) AS total
		FROM dimDate
		INNER JOIN partnerViews ON dimDate.dateID = partnerViews.dateID 
		WHERE dimDate.monthNumber = month(now())
		AND dimDate.year = year(now()) 
		AND partnerViews.partnerID = #internalPartnerID#
		</cfquery>

		<cfset result['data']['profileViews'] = q.total />


		<cfset objTools.runtime('get', '/partner/{partnerID}/dashboard/overview', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
