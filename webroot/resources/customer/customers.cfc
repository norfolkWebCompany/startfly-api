<cfcomponent extends="taffy.core.resource" taffy:uri="/customers" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="q" datasource="startfly">
			SELECT 
			coachee.*, 
			(SELECT SUM(valuePaid) FROM coacheeCourseIndex WHERE coacheeID = coachee.ID) as spendToDate,
			countries.name AS countryName  
			FROM coachee 
			LEFT JOIN countries ON coachee.country = countries.ID
		</cfquery>


			<cfset dataArray = arrayNew(1) />

			<cfif q.recordCount gt 0>

				<cfloop query="q">
					
		
					<cfset dataArray[q.currentRow]['ID'] = q.secureID />
					<cfset dataArray[q.currentRow]['firstname'] = q.firstname />
					<cfset dataArray[q.currentRow]['surname'] = q.surname />
					<cfset dataArray[q.currentRow]['address1'] = q.add1 />
					<cfset dataArray[q.currentRow]['address2'] = q.add2 />
					<cfset dataArray[q.currentRow]['address3'] = q.add3 />
					<cfset dataArray[q.currentRow]['town'] = q.town />
					<cfset dataArray[q.currentRow]['county'] = q.county />
					<cfset dataArray[q.currentRow]['country'] = q.country />
					<cfset dataArray[q.currentRow]['countryName'] = q.countryName />
					<cfset dataArray[q.currentRow]['postcode'] = q.postcode />
					<cfset dataArray[q.currentRow]['landline'] = q.landline />
					<cfset dataArray[q.currentRow]['mobile'] = q.mobile />
					<cfset dataArray[q.currentRow]['email'] = q.email />
					<cfset dataArray[q.currentRow]['gender'] = q.gender />
					<cfset dataArray[q.currentRow]['bio'] = q.bio />
					<cfset dataArray[q.currentRow]['lastBooked'] = q.lastBooked />
					<cfset dataArray[q.currentRow]['totalBookings'] = q.totalBookings />
					<cfset dataArray[q.currentRow]['avatar'] = q.avatar />

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

					<cfset dataArray[q.currentRow]['spendToDate'] = numberFormat(q.spendToDate,'.__') />

				</cfloop>

				<cfset result['data'] = dataArray />

			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>




</cfcomponent>
