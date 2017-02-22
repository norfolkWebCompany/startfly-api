<cfcomponent extends="taffy.core.resource" taffy:uri="/booking/status" hint="some hint about this resource">
	<cffunction name="post" access="public" output="false">


		<cfset objTools = createObject('component','/resources/private/tools') />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset data = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalBookingID = objTools.internalID('bookings',arguments.bookingID) />

		<cfquery datasource="startfly">
		INSERT INTO bookingConfirmation (
		bookingID,
		status,
		comments,
		created
		) VALUES (
		#internalBookingID#,
		#arguments.status#,
		'#arguments.comments#',
		NOW()
		)
		</cfquery>		

		<cfquery datasource="startfly">
		UPDATE bookings SET status = #arguments.status# 
		WHERE ID = #internalBookingID#
		</cfquery>

		<cfquery datasource="startfly">
		UPDATE bookingDetail SET status = #arguments.status# 
		WHERE bookingID = #internalBookingID#
		</cfquery>

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
