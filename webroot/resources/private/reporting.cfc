<cfcomponent>

	<cffunction name="dateStructure" access="public" returntype="struct">
		<cfargument name="data" type="struct" required="yes" />

		<cfset dates = structNew() />

		<cfloop index="i1" from="#arguments.data.startYear#" to="#arguments.data.endYear#">
			<cfif i1 is arguments.data.startYear>
				<cfloop index="i2" from="#arguments.data.startMonth#" to="12">
					<cfset sKey = i1 & numberFormat(i2,'00') />
					<cfset dates[sKey]['year'] = i1 />				
					<cfset dates[sKey]['month'] = numberFormat(i2,'00') />				
				</cfloop>
			<cfelseif i1 is arguments.data.endYear>
				<cfloop index="i2" from="1" to="#arguments.data.endMonth#">
					<cfset sKey = i1 & numberFormat(i2,'00') />
					<cfset dates[sKey]['year'] = i1 />				
					<cfset dates[sKey]['month'] = numberFormat(i2,'00') />				
				</cfloop>
			<cfelse>
				<cfloop index="i2" from="1" to="12">
					<cfset sKey = i1 & numberFormat(i2,'00') />
					<cfset dates[sKey]['year'] = i1 />				
					<cfset dates[sKey]['month'] = numberFormat(i2,'00') />				
				</cfloop>
			</cfif>

		</cfloop>


		<cfreturn dates />
	</cffunction>

</cfcomponent>