<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/customers" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalPartnerID = objTools.internalID('partner',partnerID) />

		<cfquery name="totalRecords" datasource="startfly">
		SELECT COUNT(*) AS totalRecs
		FROM partnerCustomers 
		INNER JOIN customer ON partnerCustomers.customerID = customer.ID  
		LEFT JOIN countries ON customer.country = countries.ID 
		WHERE partnerCustomers.partnerID = #internalPartnerID#
        <cfif isDefined("arguments.name") and arguments.name neq ''>
			AND CONCAT(customer.firstname,' ',customer.surname) LIKE '%#arguments.name#%'
		</cfif>
		</cfquery>

		<cfset result['pagination']['totalRecords'] = totalRecords.totalRecs />
		<cfset result['pagination']['pages'] = ceiling(totalRecords.totalRecs / arguments.pagination.limit) />


		<cfquery name="q" datasource="startfly">
		SELECT 
		customer.sID AS customerSID, 
		customer.firstname, 
		customer.surname, 
		customer.dob, 
		customer.gender, 
		customer.avatar, 
		customer.bio,
		customer.created,
		customer.town,
		partnerCustomers.dateID AS joinedDate,
		partnerCustomers.timeID AS timeJoined,
		(SELECT COUNT(*) FROM bookings WHERE customerID = customer.ID AND partnerID = #internalPartnerID#) as totalBookings,
		(SELECT SUM((net-commission)) FROM bookings WHERE customerID = customer.ID AND partnerID = #internalPartnerID#) as totalSpend,
		countries.name AS countryName  
		FROM partnerCustomers 
		INNER JOIN customer ON partnerCustomers.customerID = customer.ID  
		LEFT JOIN countries ON customer.country = countries.ID 
		WHERE partnerCustomers.partnerID = #internalPartnerID# 
        <cfif isDefined("arguments.name") and arguments.name neq ''>
			AND CONCAT(customer.firstname,' ',customer.surname) LIKE '%#arguments.name#%'
		</cfif>
		ORDER BY #arguments.orderBy.sortField# 
		<cfif arguments.orderBy.doReverse> 
		DESC
		</cfif>
		LIMIT #((arguments.pagination.currentPage * arguments.pagination.limit)-arguments.pagination.limit)#, #arguments.pagination.limit#
		</cfquery>


			<cfset dataArray = arrayNew(1) />

			<cfloop query="q">
				
	
				<cfset dataArray[q.currentRow]['ID'] = q.customerSID />
				<cfset dataArray[q.currentRow]['firstname'] = q.firstname />
				<cfset dataArray[q.currentRow]['surname'] = q.surname />
				<cfset dataArray[q.currentRow]['gender'] = q.gender />
				<cfset dataArray[q.currentRow]['bio'] = q.bio />
				<cfset dataArray[q.currentRow]['town'] = q.town />
				<cfset dataArray[q.currentRow]['totalSpend'] = q.totalSpend />
				<cfset dataArray[q.currentRow]['totalBookings'] = q.totalBookings />

				<cfif q.avatar is ''>
					<cfset dataArray[q.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/profile-avatar.png' />
				<cfelse>
					<cfset dataArray[q.currentRow]['avatar'] = 'https://beta.startfly.co.uk/images/customer/' & q.avatar />
				</cfif>


				<cfset dataArray[q.currentRow]['created'] = objDates.fromEpoch(q.created,'JSON') /> />
				<cfif q.dob neq 0>
					<cfset dataArray[q.currentRow]['dob'] = objDates.fromEpoch(q.dob,'JSON') />
				<cfelse>
					<cfset dataArray[q.currentRow]['dob'] = '' />
				</cfif>

				<cfif q.dob neq 0>
					<cfset dataArray[q.currentRow]['age'] = ceiling(( ( objDates.toEpoch(now()) - q.dob ) / 31556926 )) />
				<cfelse>
					<cfset dataArray[q.currentRow]['age'] = '' />
				</cfif>

			</cfloop>

			<cfset result['data'] = dataArray />
			<cfset result['arguments'] = arguments />


			<cfset objTools.runtime('post', '/partner/{partnerID}/customers', (getTickCount() - sTime) ) />


		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
