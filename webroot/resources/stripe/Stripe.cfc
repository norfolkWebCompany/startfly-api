<cfcomponent>

    <cffunction name="customerGet" access="public" returntype="struct">
        <cfargument name="ID" type="string" required="yes">

			<cfset result = {
				customerID = 0,
				status = 0,
				message = ''
			} />

			<cfset objSecurity = createObject("java", "java.security.Security") />
			<cfset storeProvider = objSecurity.getProvider("JsafeJCE") />
			<cfset objSecurity.removeProvider("JsafeJCE") />
	
			
			<cfhttp 
				url="https://api.stripe.com/v1/customers/#arguments.ID#" 
				method="get"
				timeout="30"
				result="customerResult" 
				username="sk_test_PgadaQclvjeLrPKR2oYbQHeB" 
				password="">
				
			</cfhttp>

		<cfset stripeResult = deserializeJSON(customerResult.fileContent) />

		<cfswitch expression="#left(customerResult.statusCode,3)#">
		<cfcase value="400">
			<cfset result.status = 0 />
			<cfset result.message = stripeResult.error.message />
		</cfcase>
		<cfcase value="402">
			<cfset result.status = 0 />
			<cfset result.message = stripeResult.error.message />
		</cfcase>
		<cfcase value="404">
			<cfset result.status = 0 />
			<cfset result.message = stripeResult.error.message />
		</cfcase>
		<cfcase value="200">
			<cfset result.status = 1 />
			<cfset result.customerID = stripeResult.ID />
			<cfset result.message = 'Customer Retrieved' />
		</cfcase>
		</cfswitch>

		<cfreturn result />
	</cffunction>
	

    <cffunction name="customerCreate" access="public" returntype="struct">
        <cfargument name="customerID" type="numeric" required="yes">

		<cfset result = {
			customerID = 0,
			status = 0,
			message = ''
		} />

		<cfquery name="thisCustomer" datasource="startfly">
		SELECT 
		email, stripeID 
		FROM customer 
		WHERE ID = #arguments.customerID#
		</cfquery>


		<cfif thisCustomer.recordCount is 0>
			<cfset result.status = 0 />
			<cfset result.message = 'Unable to find customer record' />
		<cfelse>


			<cfif thisCustomer.stripeID neq ''>
					<cfset result.status = 1 />
					<cfset result.customerID = thisCustomer.stripeID />
					<cfset result.message = 'Customer Exists' />
			<cfelse>
				<cfset objSecurity = createObject("java", "java.security.Security") />
		        <cfset storeProvider = objSecurity.getProvider("JsafeJCE") />
		        <cfset objSecurity.removeProvider("JsafeJCE") />

				
		        <cfhttp 
		        	url="https://api.stripe.com/v1/customers" 
		            method="post"
		            timeout="30"
		            result="customerResult" 
		            username="sk_test_PgadaQclvjeLrPKR2oYbQHeB" 
		            password="">
					
					<cfhttpparam type="formfield" name="email" value="#thisCustomer.email#" />

				</cfhttp>
		    
				<cfset stripeResult = deserializeJSON(customerResult.fileContent) />

				<cfswitch expression="#left(customerResult.statusCode,3)#">
				<cfcase value="400">
					<cfset result.status = 0 />
					<cfset result.message = stripeResult.error.message />
				</cfcase>
				<cfcase value="402">
					<cfset result.status = 0 />
					<cfset result.message = stripeResult.error.message />
				</cfcase>
				<cfcase value="404">
					<cfset result.status = 0 />
					<cfset result.message = 'A system error has occurred - please try again later' />
				</cfcase>
				<cfcase value="200">
					<cfset result.status = 1 />
					<cfset result.customerID = stripeResult.ID />
					<cfset result.message = 'Customer Created' />

					<cfquery datasource="startfly">
					UPDATE customer SET stripeID = '#stripeResult.ID#' 
					WHERE ID = #arguments.customerID#
					</cfquery>


				</cfcase>
				</cfswitch>
			</cfif>



		</cfif>

		
    	<cfreturn result />
    </cffunction>



    <cffunction name="cardCreate" access="public" returntype="struct">
        <cfargument name="card" type="struct" required="yes">

		<cfset result = {
			cardID = 0,
			status = 0,
			message = ''
		} />
		
		<cfset objSecurity = createObject("java", "java.security.Security") />
        <cfset storeProvider = objSecurity.getProvider("JsafeJCE") />
        <cfset objSecurity.removeProvider("JsafeJCE") />

		
        <cfhttp 
        	url="https://api.stripe.com/v1/customers/#arguments.card.customer#/cards" 
            method="post"
            timeout="1000"
            result="cardResult" 
            username="sk_test_PgadaQclvjeLrPKR2oYbQHeB" 
            password="">
			
            <cfhttpparam type="formfield" name="card[number]" value="#arguments.card.number#" />
            <cfhttpparam type="formfield" name="card[exp_month]" value="#arguments.card.exp_month#" />
            <cfhttpparam type="formfield" name="card[exp_year]" value="#arguments.card.exp_year#" />
            <cfhttpparam type="formfield" name="card[cvc]" value="#arguments.card.cvc#" />
            <cfhttpparam type="formfield" name="card[name]" value="#arguments.card.name#" />
<!---             <cfhttpparam type="formfield" name="card[address_line1]" value="#arguments.card.address_line1#" />
            <cfhttpparam type="formfield" name="card[address_line2]" value="#arguments.card.address_line2#" />
            <cfhttpparam type="formfield" name="card[address_state]" value="#arguments.card.address_state#" />
            <cfhttpparam type="formfield" name="card[address_zip]" value="#arguments.card.address_zip#" />
            <cfhttpparam type="formfield" name="card[address_country]" value="#arguments.card.address_country#" />
 --->
		</cfhttp>
    
		<cfset stripeResult = deserializeJSON(cardResult.fileContent) />

		<cfswitch expression="#left(cardResult.statusCode,3)#">
		<cfcase value="400">
			<cfset result.status = 0 />
			<cfset result.message = stripeResult.error.message />
		</cfcase>
		<cfcase value="402">
			<cfset result.status = 0 />
			<cfset result.message = stripeResult.error.message />
		</cfcase>
		<cfcase value="404">
			<cfset result.status = 0 />
			<cfset result.message = 'A system error has occurred - please try again later' />
		</cfcase>
		<cfcase value="200">
			<cfset result.status = 1 />
			<cfset result.cardID = stripeResult.ID />
			<cfset result.message = 'Card Created' />
		</cfcase>
		</cfswitch>
		
    	<cfreturn result />
    </cffunction>


    <cffunction name="chargeCreate" access="public" returntype="struct">
        <cfargument name="charge" type="struct" required="yes">

		<cfset result = {
			chargeID = 0,
			status = 0,
			message = ''
		} />
		
		<cfset objSecurity = createObject("java", "java.security.Security") />
        <cfset storeProvider = objSecurity.getProvider("JsafeJCE") />
        <cfset objSecurity.removeProvider("JsafeJCE") />

		
        <cfhttp 
        	url="https://api.stripe.com/v1/charges" 
            method="post"
            timeout="1000"
            result="chargeResult" 
            username="sk_test_PgadaQclvjeLrPKR2oYbQHeB" 
            password="">
			
            <cfhttpparam type="formfield" name="amount" value="#arguments.charge.amount#" />
            <cfhttpparam type="formfield" name="currency" value="#arguments.charge.currency#" />
            <cfhttpparam type="formfield" name="customer" value="#arguments.charge.customerID#" />
            <cfhttpparam type="formfield" name="card" value="#arguments.charge.cardID#" />
            <cfhttpparam type="formfield" name="description" value="#arguments.charge.description#" />

		</cfhttp>

		<cfset stripeResult = deserializeJSON(chargeResult.fileContent) />

		<cfswitch expression="#left(chargeResult.statusCode,3)#">
		<cfcase value="400">
			<cfset result.status = 0 />
			<cfset result.message = stripeResult.error.message />
		</cfcase>
		<cfcase value="402">
			<cfset result.status = 0 />
			<cfset result.message = stripeResult.error.message />
		</cfcase>
		<cfcase value="404">
			<cfset result.status = 0 />
			<cfset result.message = 'A system error has occurred - please try again later' />
		</cfcase>
		<cfcase value="200">
			<cfset result.status = 1 />
			<cfset result.chargeID = stripeResult.ID />
			<cfset result.message = 'Charge Completed' />
		</cfcase>
		</cfswitch>
		
    	<cfreturn result />
    </cffunction>

	

    <cffunction name="subscriptionCreate" access="public" returntype="struct">
        <cfargument name="sub" type="struct" required="yes">

		<cfset result = {
			subscriptionID = 0,
			status = 0,
			message = ''
		} />
		
		<cfset objSecurity = createObject("java", "java.security.Security") />
        <cfset storeProvider = objSecurity.getProvider("JsafeJCE") />
        <cfset objSecurity.removeProvider("JsafeJCE") />

		
        <cfhttp 
        	url="https://api.stripe.com/v1/customers/#arguments.sub.customerID#/subscriptions" 
            method="post"
            timeout="1000"
            result="subscriptionResult" 
            username="sk_test_PgadaQclvjeLrPKR2oYbQHeB" 
            password="">
			
            <cfhttpparam type="formfield" name="plan" value="#arguments.sub.plan#" />

		</cfhttp>

		<cfset stripeResult = deserializeJSON(subscriptionResult.fileContent) />

		<cfswitch expression="#left(subscriptionResult.statusCode,3)#">
		<cfcase value="400">
			<cfset result.status = 0 />
			<cfset result.message = stripeResult.error.message />
		</cfcase>
		<cfcase value="402">
			<cfset result.status = 0 />
			<cfset result.message = stripeResult.error.message />
		</cfcase>
		<cfcase value="404">
			<cfset result.status = 0 />
			<cfset result.message = 'A system error has occurred - please try again later' />
		</cfcase>
		<cfcase value="200">
			<cfset result.status = 1 />
			<cfset result.subscriptionID = stripeResult.ID />
			<cfset result.message = 'Subscription Created' />
		</cfcase>
		</cfswitch>
		
    	<cfreturn result />
    </cffunction>


    <cffunction name="createToken" access="public" returntype="struct">
        <cfargument name="card" type="struct" required="yes">
        <cfargument name="amount" type="numeric" required="yes">
        <cfargument name="currency" type="string" required="yes" default="">

		<cfset objSecurity = createObject("java", "java.security.Security") />
        <cfset storeProvider = objSecurity.getProvider("JsafeJCE") />
        <cfset objSecurity.removeProvider("JsafeJCE") />

		
        <cfhttp 
        	url="https://api.stripe.com/v1/tokens" 
            method="post"
            timeout="1000"
            result="tokenResult" 
            username="pk_test_wJXMAwXmoDLNEp6n4vYUqw6a" 
            password="">
			
			<cfhttpparam type="formfield" name="description" value="Order Test" />
            <cfhttpparam type="formfield" name="api_key" value="sk_test_PgadaQclvjeLrPKR2oYbQHeB" />
            <cfhttpparam type="formfield" name="card[number]" value="#arguments.card.number#" />
            <cfhttpparam type="formfield" name="card[exp_month]" value="#arguments.card.exp_month#" />
            <cfhttpparam type="formfield" name="card[exp_year]" value="#arguments.card.exp_year#" />
            <cfhttpparam type="formfield" name="card[cvc]" value="#arguments.card.cvc#" />
            <cfhttpparam type="formfield" name="card[name]" value="#arguments.card.name#" />
            <cfhttpparam type="formfield" name="card[address_line1]" value="#arguments.card.address_line1#" />
            <cfhttpparam type="formfield" name="card[address_line2]" value="#arguments.card.address_line2#" />
            <cfhttpparam type="formfield" name="card[address_state]" value="#arguments.card.address_state#" />
            <cfhttpparam type="formfield" name="card[address_zip]" value="#arguments.card.address_zip#" />
            <cfhttpparam type="formfield" name="card[address_country]" value="#arguments.card.address_country#" />
			<cfhttpparam type="formfield" name="currency" value="#arguments.currency#" />
			<cfhttpparam type="formfield" name="amount" value="#arguments.amount#" />


		</cfhttp>
    
		<cfset objSecurity.insertProviderAt(storeProvider, 1) />


    	<cfreturn tokenResult />
    </cffunction>
	
    <cffunction name="logPayment" access="public" returntype="numeric">
        <cfargument name="pData" type="struct" required="yes">
		
			<cfset paymentID = application.objAccum.newID('cashRcd') />
			
			<cfquery datasource="#application.dataDSN#">
			INSERT INTO cashRcd (
			payID,
			customerID,
			payDate,
			payTime,
			createdBy,
			payMeth,
			totPaid,
			authCode,
			router,
			uID,
			stripeID
			) VALUES (
			#paymentID#,
			#arguments.pData.customerID#,
			NOW(),
			NOW(),
			#arguments.pData.customerID#,
	        'CC',
			#arguments.pData.chargeValue#,
			'',
			'#arguments.pData.router#',
			#arguments.pData.uID#,
			1
			)
			</cfquery>

			<cfswitch expression="#arguments.pData.router#">
				<cfcase value="publicJobs">
					<cfquery datasource="#application.dataDSN#">
					UPDATE job SET 
					paid = paid + #arguments.pData.chargeValue#,
					paymentID = #paymentID#
					WHERE jobID = #arguments.pData.uID#
					</cfquery>
				</cfcase>

				<cfcase value="publicClassifieds">
					<cfquery datasource="#application.dataDSN#">
					UPDATE prodHead SET 
					paid = paid + #arguments.pData.chargeValue#,
					paymentID = #paymentID#
					WHERE prodCode = '#arguments.pData.uID#'
					</cfquery>
				</cfcase>
			</cfswitch>
			
	    <cfreturn paymentID />
	</cffunction>
	
    <cffunction name="localCustomerUpdate" access="public" returntype="boolean">
        <cfargument name="argCol" type="struct" required="yes">
			
			<cfquery datasource="#application.dataDSN#">
			UPDATE customer SET 
			<cfif isDefined("arguments.argCol.stripeCustomerID") >
			stripeCustomerID = '#arguments.argCol.stripeCustomerID#',
			</cfif>
			<cfif isDefined("arguments.argCol.stripeCardID") >
			stripeCardID = '#arguments.argCol.stripeCardID#',
			</cfif>
			LastAmended = NOW()			
			WHERE cID = #arguments.argCol.cID#
			</cfquery>		

		<cfreturn true />
	</cffunction>

		
</cfcomponent>