<cfcomponent extends="taffy.core.resource" taffy:uri="/epochToDim" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objDates = createObject('component','/resources/private/dates') />

		<cfset result = {} />
		<cfset result.date = {} />
		
		<cfquery name="oc" datasource="startfly">
		SELECT starts, ends,ID 
		FROM listingOccurrence 
		</cfquery>

		<cfloop query="oc">
			
			<cfset thisStartDate = objDates.fromEpoch(oc.starts) />
			<cfset thisEndDate = objDates.fromEpoch(oc.ends) />

	        <cfset startDim = objDates.setDim(
	        	{
	        		dateTime = thisStartDate
	        	}
	        ) />

	        <cfset endDim = objDates.setDim(
	        	{
	        		dateTime = thisEndDate
	        	}
	        ) />

	        <cfquery datasource="startfly">
		    UPDATE listingOccurrence SET 
		    startDateID = #startDim.dateID#,
		    startTimeID = #startDim.timeID#,
		    endDateID = #endDim.dateID#,
		    endTimeID = #endDim.timeID# 
		    WHERE ID = #oc.ID#
	        </cfquery>

		</cfloop>

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


</cfcomponent>
