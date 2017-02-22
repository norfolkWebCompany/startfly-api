<cfcomponent extends="taffy.core.resource" taffy:uri="/messages/customer/{customerID}" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">
		<cfargument name="customerID" type="string" required="true" />


		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfquery name="thisCustomer" datasource="startfly">
		SELECT email 
		FROM customer 
		WHERE ID = #internalCustomerID#
		</cfquery>




		<cfif isDefined("arguments.startDate") and arguments.startDate neq ''>
			<cfset sDate = objTools.cfDateFromJSON(arguments.startDate) />
			<cfset sDate = objTools.rootDay(sDate) />
			<cfset sDateSQL = 'AND messages.rootDay >= ' & #sDate# />
		<cfelse>
			<cfset sDateSQL = '' />
		</cfif>

		<cfif isDefined("arguments.endDate") and arguments.endDate neq ''>
			<cfset eDate = objTools.cfDateFromJSON(arguments.endDate) />
			<cfset eDate = objTools.rootDay(eDate) />
			<cfset eDateSQL = 'AND messages.rootDay <= ' & #eDate# />
		<cfelse>
			<cfset eDateSQL = '' />
		</cfif>

		<cfswitch expression="#arguments.folder#">
			<cfcase value="sent">
				<cfset addressSQL = 'AND messages.sentFrom = "' & thisCustomer.email & '"' />				
			</cfcase>
			<cfdefaultcase>
				<cfset addressSQL = 'AND messages.sentTo = "' & thisCustomer.email & '"' />				
			</cfdefaultcase>
		</cfswitch>


		<cfquery name="totalRecords" datasource="startfly">
		SELECT COUNT(*) AS totalRecs
		FROM messages 
		<cfif arguments.folder is 'sent'>
			LEFT JOIN partner ON partner.email = messages.sentTo  
		<cfelse>
			LEFT JOIN partner ON partner.email = messages.sentFrom  
		</cfif>
		WHERE 0=0 
		<cfif arguments.folder is 'deleted'>
		AND messages.deleted = 1 
		<cfelse>
		AND messages.deleted = 0 
		</cfif>
		<cfif arguments.folder is 'flagged'>
		AND messages.flagged = 1 
		</cfif>
		#addressSQL# 
		#sDateSQL#
		#eDateSQL#
        <cfif isDefined("arguments.subject") and arguments.subject neq ''>
        AND messages.subject LIKE '%#arguments.subject#%' 
        </cfif>
		</cfquery>

		<cfset result['pagination']['totalRecords'] = totalRecords.totalRecs />
		<cfset result['pagination']['pages'] = ceiling(totalRecords.totalRecs / arguments.pagination.limit) />

		<cfquery name="messages" datasource="startfly" result="qResult">
		SELECT 
		messages.ID,
		messages.sID as messageSID,
		messages.parentID,
		messages.type,
		messages.subject,
		messages.content,
		messages.folder,
		messages.read,
		messages.flagged,
		messages.deleted,
		messages.rootDay,
		messages.dateID,
		messages.timeID,
		partner.firstname,
		partner.surname 
		FROM messages 
		<cfif arguments.folder is 'sent'>
			LEFT JOIN partner ON partner.email = messages.sentTo  
		<cfelse>
			LEFT JOIN partner ON partner.email = messages.sentFrom  
		</cfif>
		WHERE 0=0 
		<cfif arguments.folder is 'deleted'>
		AND messages.deleted = 1 
		<cfelse>
		AND messages.deleted = 0 
		</cfif>
		<cfif arguments.folder is 'flagged'>
		AND messages.flagged = 1 
		</cfif>
		#addressSQL# 
		#sDateSQL#
		#eDateSQL#
        <cfif isDefined("arguments.subject") and arguments.subject neq ''>
        AND messages.subject LIKE '%#arguments.subject#%' 
        </cfif>
		ORDER BY #arguments.orderBy.sortField# 
		<cfif arguments.orderBy.doReverse> 
		DESC
		</cfif>
		LIMIT #((arguments.pagination.currentPage * arguments.pagination.limit)-arguments.pagination.limit)#, #arguments.pagination.limit#
		</cfquery>


			<cfset dataArray = arrayNew(1) />

			<cfif messages.recordCount gt 0>

				<cfloop query="messages">
					
		
					<cfset dataArray[messages.currentRow]['ID'] = messages.messageSID />
					<cfset dataArray[messages.currentRow]['parentID'] = messages.parentID />
					<cfset dataArray[messages.currentRow]['subject'] = messages.subject />
					<cfset dataArray[messages.currentRow]['content'] = messages.content />
					<cfset dataArray[messages.currentRow]['name'] = messages.firstname & ' ' & messages.surname />
					<cfset dataArray[messages.currentRow]['flagged'] = messages.flagged />
					<cfset dataArray[messages.currentRow]['read'] = messages.read />
					<cfset dataArray[messages.currentRow]['deleted'] = messages.deleted />
					<cfset dataArray[messages.currentRow]['folder'] = messages.folder />
					<cfset dataArray[messages.currentRow]['sendDate'] = objDates.getDim(messages.dateID,messages.timeID,'JSON') /> />

				</cfloop>

				<cfset result['data'] = dataArray />

			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>

			<cfset objTools.runtime('get', '/messages/customer/{customerID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
