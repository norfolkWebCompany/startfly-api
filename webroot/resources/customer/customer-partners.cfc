<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/partners" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="customerID" type="string" required="true" />

			<cfset result = {} />
			<cfset result['status'] = {} />
			<cfset dataArray = {} />
			<cfset result['status']['statusCode'] = 200 />
			<cfset result['status']['message'] = 'OK' />

			<cfset objTools = createObject('component','/resources/private/tools') />
			<cfset sTime = getTickCount() />

			<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />


			<cfquery name="partners" datasource="startfly">
			SELECT 
			partner.sID,
			CONCAT(partner.firstname,' ',partner.surname) AS partnerName
			FROM bookingDetail 
			INNER JOIN partner ON bookingDetail.partnerID = partner.ID 
			WHERE bookingDetail.customerID = #internalCustomerID# 
			GROUP BY partnerName
			ORDER BY partnerName
			</cfquery>


			<cfset dataArray = arrayNew(1) />

			<cfloop query="partners">
				<cfset dataArray[partners.currentRow]['ID'] = partners.sID />
				<cfset dataArray[partners.currentRow]['name'] = partners.partnerName />
			</cfloop>

			<cfset result['data'] = dataArray />

			<cfset objTools.runtime('get', '/customer/{customerID}/partners', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
