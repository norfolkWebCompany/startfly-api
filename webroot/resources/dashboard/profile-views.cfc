<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/reporting/profile" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="endYear" type="numeric" required="true" default="#year(now())#" />
		<cfargument name="endMonth" type="numeric" required="true" default="#month(now())#" />
		<cfargument name="startYear" type="numeric" required="true" default="#year(now())-1#" />
		<cfargument name="startMonth" type="numeric" required="true" default="#month(now())#" />


		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />


		<cfset startYear = arguments.startYear />
		<cfset startMonth = arguments.startMonth />

		<cfset endYear = arguments.endYear />
		<cfset endMonth = arguments.endMonth />


		<cfset labels = arrayNew(1) />
		<cfset data = arrayNew(1) />
		<cfset series = arrayNew(1) />

		<cfset countData = arrayNew(1) />

		<cfloop index="y" from="#startYear#" to="#endYear#">

			<cfif y is startYear>
				<cfloop index="sm" from="#startMonth#" to="12">
					<cfset labels[arrayLen(labels) + 1] = left(monthAsString(sm),3) & ' ' &  y /> 

					<cfquery name="q" datasource="startfly">
					SELECT 
					IFNULL(sum(partnerViews.views), 0) AS total
					FROM partnerViews 
					WHERE partnerViews.theMonth = #numberFormat(sm,'00')#
					AND partnerViews.theYear = #y# 
					AND partnerViews.partnerID = #internalPartnerID#
					</cfquery>

					<cfset countData[arrayLen(countData) + 1] = q.total />

				</cfloop>

			<cfelseif y is endYear>
				<cfloop index="em" from="1" to="#endMonth#">
					<cfset labels[arrayLen(labels) + 1] = left(monthAsString(em),3) & ' ' &  y /> 

					<cfquery name="q" datasource="startfly">
					SELECT 
					IFNULL(sum(partnerViews.views), 0) AS total
					FROM partnerViews 
					WHERE partnerViews.theMonth = #numberFormat(em,'00')#
					AND partnerViews.theYear = #y#
					AND partnerViews.partnerID = #internalPartnerID#
					</cfquery>

					<cfset countData[arrayLen(countData) + 1] = q.total />

				</cfloop>

			<cfelse>
				<cfloop index="mm" from="1" to="12">
					<cfset labels[arrayLen(labels) + 1] = left(monthAsString(mm),3) & ' ' &  y /> 

					<cfquery name="q" datasource="startfly">
					SELECT 
					IFNULL(sum(partnerViews.views), 0) AS total
					FROM partnerViews 
					WHERE partnerViews.theMonth = #numberFormat(mm,'00')#
					AND partnerViews.theYear = #y#
					AND partnerViews.partnerID = #internalPartnerID#
					</cfquery>

					<cfset countData[arrayLen(countData) + 1] = q.total />

				</cfloop>
			</cfif>


		</cfloop>

		<cfset series[1] = 'Count' />

		<cfset result['data']['labels'] = labels />
		<cfset result['data']['data'] = arrayNew(1) />
		<cfset arrayAppend(result['data']['data'],countData) />
		<cfset result['data']['series'] = series />

		<cfset result['data']['totalsPeriod']['count'] = arraySum(countData) />

		<cfquery name="qYear" datasource="startfly">
		SELECT 
		IFNULL(sum(partnerViews.views), 0) AS total
		FROM partnerViews 
		WHERE partnerViews.theYear = #year(now())# 
		AND partnerViews.partnerID = #internalPartnerID#
		</cfquery>

		<cfquery name="qMonth" datasource="startfly">
		SELECT 
		IFNULL(sum(partnerViews.views), 0) AS total
		FROM partnerViews 
		WHERE partnerViews.theYear = #year(now())# 
		AND partnerViews.theMonth = #month(now())#
		AND partnerViews.partnerID = #internalPartnerID#
		</cfquery>


		<cfset result['data']['totalsYear']['count'] = qYear.total />
		<cfset result['data']['totalsMonth']['count'] = qMonth.total />

		<cfset objTools.runtime('get', '/partner/{partnerID}/reporting/profile', (getTickCount() - sTime) ) />


		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
