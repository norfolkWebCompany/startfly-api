<cfcomponent>
	<cffunction name="runtime" access="public" returntype="any">
		<cfargument name="verb" type="string" required="yes">
		<cfargument name="apiPoint" type="string" required="yes">
		<cfargument name="runtime" type="numeric" required="yes">

		<cfquery datasource="startfly">
		INSERT INTO runtime (
		verb,
		apiPoint,
		runtime,
		created
		) VALUES (
		'#arguments.verb#',
		'#arguments.apiPoint#',
		#arguments.runtime#,
		NOW()
		)
		</cfquery>

		<cfreturn true />
	</cffunction>

	<cffunction name="internalID" access="public" returntype="any">
		<cfargument name="table" type="string" required="yes">
		<cfargument name="sID" type="string" required="yes">

			<cfquery name="internal" datasource="startfly">
			SELECT ID 
			FROM #arguments.table# 
			WHERE sID = '#arguments.sID#' 
			LIMIT 1
			</cfquery>

			<cfif internal.recordCount is 1>
				<cfset result = internal.ID />
			<cfelse>
				<cfset result = 0 />
			</cfif>


		<cfreturn result />
	</cffunction>


	<cffunction name="secureID" access="public" returntype="string">

		<cfset uuidLeft = listFirst(createUUID(),'-') />
		<cfset uuidRight = listLast(createUUID(),'-') />

		<cfset sID = getTickCount() & uuidLeft & uuidRight />

		<cfreturn sID />
	</cffunction>


	<cffunction name="setTOC" access="public" returntype="struct">
		<cfargument name="theDate" type="date" required="yes">

		<cfset toc = createDate(1900,01,01) />

		<cfset result = {
			trueDate = arguments.theDate,
			daysSinceToc = 0,
			year = year(arguments.theDate),
			month = month(arguments.theDate),
			day = day(arguments.theDate),
			hour = hour(arguments.theDate),
			minute = minute(arguments.theDate)
		} />

		<cfset result.daysSinceToc = dateDiff('D',toc,arguments.theDate) />

		<cfreturn result />
	</cffunction>

	<cffunction name="dateFromTOC" access="public" returntype="struct">
		<cfargument name="day" type="numeric" required="yes">
		<cfargument name="hour" type="numeric" required="no" default="0">
		<cfargument name="minute" type="numeric" required="no" default="0">

		<cfset tocDateTime = createDateTime(1900,01,01,arguments.hour,arguments.minute,0) />

		<cfset trueDateTime = dateAdd('D',arguments.day,tocDateTime) />


		<cfset result = {
			cfDate = dateAdd('D',arguments.day,toc),
			JSONDate = dateFormat(trueDateTime, "yyyy-mm-dd") & 'T' & timeFormat(trueDateTime,"HH:mm:ss") & 'Z'
		} />

		<cfreturn result />
	</cffunction>



	<cffunction name="rootDay" access="public" returntype="numeric">
		<cfargument name="theDate" type="date" required="yes">

		<cfset groundZero = createDate(1900,01,01) />

		<cfset rDay = dateDiff('D',groundZero,arguments.theDate) />

		<cfreturn rDay />
	</cffunction>

	<cffunction name="fromRootDay" access="public" returntype="numeric">
		<cfargument name="rootDay" type="numeric" required="yes">

		<cfset groundZero = createDate(1900,01,01) />

		<cfset rDate = dateAdd('D',arguments.rootDay,groundZero) />

		<cfreturn rDate />
	</cffunction>

	<cffunction name="cfDate" access="public" returntype="numeric">
		<cfargument name="theDate" type="date" required="yes">

		<cfset newDate = dateFormat(arguments.theDate,'dd/mm/yyyy') />

		<cfset theDay = listGetAt(newDate,1,'/') />
		<cfset theMonth = listGetAt(newDate,2,'/') />
		<cfset theYear = listGetAt(newDate,3,'/') />

		<cfset cfDate = createDateTime(theYear,theMonth, theDay,6,0,0) />

		<cfreturn cfDate />
	</cffunction>

	<cffunction name="cfDateFromJSON" access="public" returntype="numeric">
		<cfargument name="theDate" type="string" required="yes">
		<cfargument name="delimiter" type="string" required="no" default="-">
		<cfargument name="addTime" type="numeric" required="no" default="1">

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

		<cfif arguments.addTime is 1>
			<cfset cfDate = createDateTime(theYear,theMonth, theDay,6,0,0) />
		<cfelse>
			<cfset cfDate = createDate(theYear,theMonth, theDay) />
		</cfif>

		<cfreturn cfDate />
	</cffunction>

	<cffunction name="minutesToHours" access="public" returntype="struct">
		<cfargument name="minutes" type="numeric" required="yes">

		<cfset result = {
			hour = 0,
			min  = 0
		} />

		<cfset result.hour = int((arguments.minutes / 60)) />
		<cfset result.min = arguments.minutes - int((arguments.minutes / 60)) />

		<cfreturn result />
	</cffunction>

	<cffunction name="hoursToMinutes" access="public" returntype="numeric">
		<cfargument name="hours" type="numeric" required="yes" default="0">
		<cfargument name="minutes" type="numeric" required="yes" default="0">

		<cfset result = 0 />

		<cfset result = ((arguments.hours * 60) + arguments.minutes) />

		<cfreturn result />
	</cffunction>


	<cffunction name="cleanURL" access="public" returntype="struct">
		<cfargument name="url" type="string" required="yes">

		<cfset result = {
			URLExists = 0,
			cleanURL  = ''
		} />


		<cfset cleanedURL = trim(lCase(arguments.URL)) />

		<cfset cleanedURL = replace(cleanedURL,'!','','ALL') />
		<cfset cleanedURL = replace(cleanedURL,'?','','ALL') />
		<cfset cleanedURL = replace(cleanedURL,'-','-','ALL') />
		<cfset cleanedURL = replace(cleanedURL,'/','-','ALL') />
		<cfset cleanedURL = replace(cleanedURL,'\','-','ALL') />
		<cfset cleanedURL = replace(cleanedURL,' ','-','ALL') />
		<cfset cleanedURL = replace(cleanedURL,'"','','ALL') />
		<cfset cleanedURL = replace(cleanedURL,',','','ALL') />
		<cfset cleanedURL = replace(cleanedURL,'&','and','ALL') />
		<cfset cleanedURL = replace(cleanedURL,"'","","ALL") />
		<cfset cleanedURL = replace(cleanedURL,'-----','-','ALL') />
		<cfset cleanedURL = replace(cleanedURL,'----','-','ALL') />
		<cfset cleanedURL = replace(cleanedURL,'---','-','ALL') />
		<cfset cleanedURL = replace(cleanedURL,'--','-','ALL') />

		<cfquery name="dupeCheck" datasource="startfly">
		SELECT listing.ID 
		FROM listing 
		WHERE URL = '#cleanedURL#' 
		AND deleted = 0
		LIMIT 1
		</cfquery>

		<cfif dupeCheck.recordCount is 1>
			<cfset result.URLExists = 1 />
			<cfset cleanedURL = cleanedURL & '-' & getTickCount() />
		</cfif>

		<cfset result.cleanURL = cleanedURL />

		<cfreturn result />

	</cffunction>

	<cffunction name="toHTML" access="public" returntype="string">
		<cfargument name="html" type="string" required="yes">

		<cfset result = REReplace(arguments.html,"#chr(13)#|#chr(9)#","<br /><br />","ALL") />
		<cfset result = REReplace(result,"\n|\r","<br />","ALL") />


		<cfreturn result />

	</cffunction>
</cfcomponent>