<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{ownerID}/card/{cardID}" hint="some hint about this resource">
	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="q" datasource="startfly">
		SELECT 
		cards.*
		FROM cards 
		WHERE ownerID = #arguments.customerID# 
		AND cardID = #arguments.cardID#
		AND cards.deleted = 0 
		</cfquery>


			<cfif q.recordCount gt 0>

				<cfloop query="q">
					<cfset result['data']['ID'] = q.sID />
					<cfset result['data']['cardName'] = q.cardName />
					<cfset result['data']['lastFour'] = q.lastFour />
					<cfset result['data']['isDefault'] = q.isDefault />
					<cfset result['data']['expireMonth'] = q.expireMonth />
					<cfset result['data']['expireYear'] = q.expireYear />
				</cfloop>

			<cfelse>
				<cfset result['status']['statusCode'] = 500 />
				<cfset result['status']['message'] = 'Unable to locate data record' />
			</cfif>


		<cfset objTools.runtime('get', '/customer/{ownerID}/card/{cardID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">
		<cfargument name="cardName" type="string" required="true" />
		<cfargument name="cardNumber" type="string" required="true" />
		<cfargument name="startMonth" type="string" required="true" />
		<cfargument name="startYear" type="string" required="true" />
		<cfargument name="CVV" type="string" required="true" />
		<cfargument name="isDefault" type="numeric" required="true" />

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfset err = arrayNew(1) />

		<cfset okToPost = 1 />

		<cfif arguments.cardname is ''>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Please name as it appears on card') />
		</cfif>

		<cfif arguments.cardNumber is ''>
			<cfset okToPost = 0 />
			<cfset arrayAppend(err,'Please enter long card number') />
		</cfif>


		<cfif okToPost is 1>


			<cfif isDefault is 1>
				<cfquery datasource="startfly">
				UPDATE cards SET 
				isDefault = 0 
				WHERE ownerID = #arguments.customerID#
				</cfquery>
			</cfif>

			<cfquery datasource="startfly">
			UPDATE cards SET 
			cardname = '#arguments.cardName#',
			lastFour = '#right(arguments.cardnumber,4)#',
			expireMonth = '#arguments.expireMonth#',
			expireYear = '#arguments.expireYear#',
			isDefault = #arguments.isDefault# 
			WHERE sID = '#arguments.cardID#'
			</cfquery>

		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'An error occurred' />
			<cfset result['errors'] = err />			
		</cfif>

		<cfset objTools.runtime('post', '/customer/{ownerID}/card/{cardID}', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="delete" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery datasource="startfly">
		UPDATE cards SET deleted = 1 
		WHERE sID = '#arguments.cardID#'
		</cfquery>

		<cfset objTools.runtime('delete', '/customer/{ownerID}/card/{cardID}', (getTickCount() - sTime) ) />


		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>
</cfcomponent>
