<cfcomponent>
	<cffunction name="dimNow" access="public" returntype="struct">

		<cfset result = {} />

		<cfquery name="d" datasource="startfly">
		SELECT dateID 
		FROM dimDate 
		WHERE date = '#dateFormat(now(),'yyyy-mm-dd')#'
		LIMIT 1
        </cfquery>

        <cfset result['dateID'] = d.dateID />

		<cfquery name="t" datasource="startfly">
		SELECT timeID 
		FROM dimTime 
		WHERE theHour = #hour(now())# 
		AND theMinute = #minute(now())#
		LIMIT 1
        </cfquery>

        <cfset result['timeID'] = t.timeID />

		<cfreturn result />
	</cffunction>



	<cffunction name="getDim" access="public" returntype="any">
		<cfargument name="dateID" type="numeric" required="yes" />
		<cfargument name="timeID" type="numeric" required="yes" default="" />
		<cfargument name="format" type="string" required="no" default="" />

		<cfquery name="d" datasource="startfly">
		SELECT date 
		FROM dimDate 
		WHERE dateID = #arguments.dateID#
		LIMIT 1
		</cfquery>

		<cfquery name="t" datasource="startfly">
		SELECT theHour, theMinute 
		FROM dimTime 
		WHERE timeID = #arguments.timeID#
		LIMIT 1
		</cfquery>

		<cfset theDate = dateAdd('n', ((t.theHour * 60) + t.theMinute), d.date ) />

		<cfswitch expression="#arguments.format#">
			<cfcase value="CF">
			</cfcase>
			<cfcase value="JSON">
				<cfset result = dateFormat(theDate, "yyyy-mm-dd") & 'T' & timeFormat(theDate,"HH:mm:ss") & 'Z' />
			</cfcase>
			<cfdefaultcase>
				<cfset result = theDate />				
			</cfdefaultcase>
		</cfswitch>


		<cfreturn result />
	</cffunction>

	<cffunction name="setDim" access="public" returntype="struct">
		<cfargument name="data" type="struct" required="yes">

		<cfset result = {
			dateID = 0,
			timeID = 0
		} />

		<cfif isDefined('arguments.data.date')>

			<cfif listContains(arguments.data.date,'/')>

				<cfset theDay = listGetAt(arguments.data.date,1,'/') />
				<cfset theMonth = listGetAt(arguments.data.date,2,'/') />
				<cfset theYear = listGetAt(arguments.data.date,3,'/') />

				<cfset theDate = createDate(theYear,theMonth,theDay) />

				<cfquery name="d" datasource="startfly">
				SELECT dateID 
				FROM dimDate 
				WHERE date = #theDate#
				LIMIT 1
	            </cfquery>
<!--- 			<cfelseif listContains(arguments.data.date,'-')>
				<cfset theDay = listGetAt(arguments.data.date,3,'-') />
				<cfset theMonth = listGetAt(arguments.data.date,2,'-') />
				<cfset theYear = listGetAt(arguments.data.date,1,'-') />

				<cfset theDate = createDate(theYear,theMonth,theDay) />

				<cfquery name="d" datasource="startfly">
				SELECT dateID 
				FROM dimDate 
				WHERE date = #theDate#
				LIMIT 1
	            </cfquery>
 --->
			<cfelse>
				<cfquery name="d" datasource="startfly">
				SELECT dateID 
				FROM dimDate 
				WHERE date = <cfqueryparam value="#arguments.data.date#" cfsqltype="CF_SQL_DATE" /> 
				LIMIT 1
	            </cfquery>
			</cfif>

            <cfif d.recordCount is 1>
				<cfset result.dateID = d.dateID />	            
            </cfif>

		</cfif>

		<cfif isDefined('arguments.data.dateTime')>

			<cfquery name="d" datasource="startfly">
			SELECT dateID 
			FROM dimDate 
			WHERE date = <cfqueryparam value="#arguments.data.dateTime#" cfsqltype="CF_SQL_DATE" /> 
			LIMIT 1
            </cfquery>

            <cfif d.recordCount is 1>
				<cfset result.dateID = d.dateID />	            
            </cfif>

			<cfset theHour = hour(arguments.data.dateTime) />
			<cfset theMinute = minute(arguments.data.dateTime) />

			<cfquery name="t" datasource="startfly">
			SELECT timeID 
			FROM dimTime 
			WHERE theHour = #theHour# 
			AND theMinute = #theMinute#
			LIMIT 1
            </cfquery>

            <cfif t.recordCount is 1>
				<cfset result.timeID = t.timeID />	            
            </cfif>

		</cfif>

		<cfif isDefined('arguments.data.time')>

			<cfset theHour = listFirst(arguments.data.time,':') />
			<cfset theMinute = listLast(arguments.data.time,':') />

			<cfquery name="t" datasource="startfly">
			SELECT timeID 
			FROM dimTime 
			WHERE theHour = #theHour# 
			AND theMinute = #theMinute#
			LIMIT 1
            </cfquery>

            <cfif t.recordCount is 1>
				<cfset result.timeID = t.timeID />	            
            </cfif>

		</cfif>


		<cfif isDefined('arguments.data.hour')>

			<cfparam name="arguments.data.minute" default="0" />

			<cfquery name="t" datasource="startfly">
			SELECT timeID 
			FROM dimTime 
			WHERE theHour = #arguments.data.hour# 
			AND theMinute = #arguments.data.minute#
			LIMIT 1
            </cfquery>

            <cfif t.recordCount is 1>
				<cfset result.timeID = t.timeID />	            
            </cfif>

		</cfif>

		<cfreturn result />
	</cffunction>


	<cffunction name="toEpoch" access="public" returntype="any">
		<cfargument name="theDate" type="date" required="yes">

			<cfset epTime = DateDiff("s",DateConvert("utc2Local", "January 1 1970 00:00"), arguments.theDate) />

		<cfreturn epTime />
	</cffunction>


	<cffunction name="fromEpoch" access="public" returntype="any">
		<cfargument name="ep" type="numeric" required="yes">
		<cfargument name="format" type="string" required="no" default="">

			<cfset returnDate = dateAdd('s',arguments.ep,DateConvert("utc2Local", "January 1 1970 00:00")) />

			<cfif arguments.format is 'JSON'>
				<cfset returnDate = dateFormat(returnDate, "yyyy-mm-dd") & 'T' & timeFormat(returnDate,"HH:mm:ss") & 'Z' />
			</cfif>

		<cfreturn returnDate />
	</cffunction>


	<cffunction name="toCF" access="public" returntype="any">
		<cfargument name="theDate" type="date" required="yes">
		<cfargument name="format" type="string" required="no" default="">
		<cfargument name="delimiter" type="string" required="no" default="-">

			<cfswitch expression="#arguments.format#">
				<cfcase value="JSON">
					<cfset newDate = listFirst(arguments.theDate,'T') />

					<cfif arguments.delimiter is '-'>
						<cfset theYear = listGetAt(newDate,1,'-') />
						<cfset theMonth = listGetAt(newDate,2,'-') />
						<cfset theDay = listGetAt(newDate,3,'-') />
					<cfelse>
						<cfset theYear = listGetAt(newDate,3,'/') />
						<cfset theMonth = listGetAt(newDate,2,'/') />
						<cfset theDay = listGetAt(newDate,1,'/') />
					</cfif>

					<cfset returnDate = createDateTime(theYear,theMonth, theDay,6,0,0) />
				</cfcase>
				<cfdefaultcase>
					<cfset newDate = dateFormat(arguments.theDate,'dd/mm/yyyy') />

					<cfset theDay = listGetAt(newDate,1,'/') />
					<cfset theMonth = listGetAt(newDate,2,'/') />
					<cfset theYear = listGetAt(newDate,3,'/') />

					<cfset returnDate = createDateTime(theYear,theMonth, theDay,6,0,0) />
				</cfdefaultcase>
			</cfswitch>

		<cfreturn returnDate />
	</cffunction>


	<cffunction name="toJSON" access="public" returntype="any">
		<cfargument name="theDate" type="date" required="yes">

			<cfset returnDate = dateFormat(arguments.theDate, "yyyy-mm-dd") & 'T' & timeFormat(arguments.theDate,"HH:mm:ss") & 'Z' />

		<cfreturn returnDate />
	</cffunction>

</cfcomponent>