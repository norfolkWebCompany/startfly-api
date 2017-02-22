<cfcomponent extends="taffy.core.resource" taffy:uri="/customer/{customerID}/cards" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="q" datasource="startfly">
		SELECT 
		cards.*
		FROM cards 
		WHERE ownerID = #internalCustomerID# 
		AND cards.deleted = 0 
		ORDER BY isDefault DESC 
		</cfquery>

		<cfset dataArray = arrayNew(1) />

		<cfloop query="q">
			<cfset dataArray[q.currentRow]['ID'] = q.sID />
			<cfset dataArray[q.currentRow]['cardName'] = q.cardName />
			<cfset dataArray[q.currentRow]['lastFour'] = q.lastFour />
			<cfset dataArray[q.currentRow]['isDefault'] = q.isDefault />
			<cfset dataArray[q.currentRow]['expireMonth'] = q.expireMonth />
			<cfset dataArray[q.currentRow]['expireYear'] = q.expireYear />
		</cfloop>

		<cfset result['data'] = dataArray />

		<cfset objTools.runtime('get', '/customer/{customerID}/cards', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>


	<cffunction name="post" access="public" output="false">

		<cfset objTools = createObject('component','/resources/private/tools') />
		<cfset sTime = getTickCount() />

		<cfset objStripe = createObject('component','/resources/stripe/stripe') />

		<cfset internalCustomerID = objTools.internalID('customer',arguments.customerID) />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />
		<cfset result['args'] = arguments />

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

			<cfset stripeCustomer = {
				customerID = internalCustomerID
			} />


			<cfset stripeCustomerResult = objStripe.customerCreate(internalCustomerID) />

			<cfif stripeCustomerResult.status is 1>

				<cfset stripeCard = {
					customer = stripeCustomerResult.customerID,
					name = arguments.cardname,
					number = arguments.cardnumber,
					exp_month = arguments.expireMonth,
					exp_year = arguments.expireYear,
					cvc = arguments.cvv
				} />

				<cfset stripeCardAddResult = objStripe.cardCreate(stripeCard) />

				<cfif stripeCardAddResult.status is 1>
						<cfset objAccum = createObject('component','/resources/private/accum') />

						<cfset sID = objTools.secureID() />

						<cfset isDefault = arguments.isDefault />

						<cfif arguments.isDefault is 1>
							<cfquery datasource="startfly">
							UPDATE cards SET 
							isDefault = 0
							WHERE ownerID = #internalCustomerID#
							</cfquery>
						</cfif>

						<cfquery name="cardCount" datasource="startfly">
						SELECT * 
						FROM cards 
						WHERE ownerID = #internalCustomerID#
						AND Deleted = 0
						</cfquery>

						<cfif cardCount.recordCount is 0>
							<cfset isDefault = 1 /> 
						</cfif>

						<cfquery datasource="startfly" result="qResult">
						INSERT INTO cards (
						sID,
						ownerID,
						ownerType,
						cardname,
						lastFour,
						expireMonth,
						expireYear,
						isDefault,
						stripeID,
						created
						) VALUES (
						'#sID#',
						#internalCustomerID#,
						'customer',
						'#arguments.cardname#',
						'#right(arguments.cardnumber,4)#',
						#arguments.expireMonth#,
						#arguments.expireYear#,
						#isDefault#,
						'#stripeCardAddResult.cardID#',
						NOW()
						)
						</cfquery>

						<cfset result['data']['stripeCustomer'] = stripeCustomerResult />
						<cfset result['data']['stripeCardAdd'] = stripeCardAddResult />

						<cfset result['data']['ID'] = sID />
						<cfset result['data']['cardName'] = arguments.cardName />
						<cfset result['data']['lastFour'] = right(arguments.cardnumber,4) />
						<cfset result['data']['expireMonth'] = arguments.expireMonth />
						<cfset result['data']['expireYear'] = arguments.expireYear />
						<cfset result['data']['isDefault'] = isDefault />
						<cfset result['data']['cardCount'] = cardCount.recordCount + 1 />
				<cfelse>
						<cfset result['data']['stripeCardAdd'] = stripeCardAddResult />


						<cfset okToPost = 0 />
						<cfset arrayAppend(err,stripeCardAddResult.message) />
				</cfif>




			<cfelse>

				<cfset result['data']['stripeCustomer'] = stripeCustomerResult />
				<cfset okToPost = 0 />
				<cfset arrayAppend(err,stripeCustomerResult.message) />

			</cfif>





		<cfelse>
			<cfset result['status']['statusCode'] = 500 />
			<cfset result['status']['message'] = 'An error occurred' />
			<cfset result['errors'] = err />			
		</cfif>


		<cfset result['errors'] = err />			

		<cfset objTools.runtime('post', '/customer/{customerID}/cards', (getTickCount() - sTime) ) />

		<cfreturn representationOf(result).withStatus(200) />
	</cffunction>

</cfcomponent>
