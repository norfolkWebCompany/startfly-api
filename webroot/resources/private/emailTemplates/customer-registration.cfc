<cfcomponent>
    <cffunction name="send" access="public" returntype="any">
       <cfargument name="customerID" type="numeric" required="true" /> 

        <cfset objTools = createObject('component','/resources/private/tools') />
        <cfset objEmail = createObject('component','/resources/private/email') />


        <cfquery name="thisCustomer" datasource="startfly">
        SELECT firstname, surname, email, sID 
        FROM customer 
        WHERE ID = #arguments.customerID#
        </cfquery>


        <cfsavecontent variable="request_body">
            <cfoutput>
            <Subscriber>
                <EmailAddress>#trim(thisCustomer.email)#</EmailAddress>
                <Name>#trim(thisCustomer.firstname)# #trim(thisCustomer.surname)#</Name>
            </Subscriber>
            </cfoutput>
        </cfsavecontent>

        <cfset thisURL = 'https://api.createsend.com/api/v3.1/subscribers/1739ce83cec319749a6069c1e4a7274e.xml' />

        <cfhttp 
        url="#thisURL#" 
        method="post"
        username="72d3c8a2cbbf08caa7dab9a8f2174386" 
        password="">
            <cfhttpparam type="header" name="accept-encoding" value="no-compression" />
            <cfhttpparam type="xml" value="#trim(request_body)#" />
        </cfhttp>



<!---         <cfsavecontent variable="emailContent">
        <cfoutput>
        <h2>Thank you for registering with Startfly</h2>
        <p>Your activation code is: #thisCustomer.activationCode#</p>
        <p>Your account can be activated by clicking the following link</p>
        <p><a href="http://beta.startfly.co.uk/##/partner/registration/activate/#thisCustomer.sID#">Activate Account</a></p>
        </cfoutput>
        </cfsavecontent>

        <cfset emailData = {
            sendTo = thisCustomer.email,
            sendFrom = 'hello@startfly.co.uk',
            subject = 'Startfly Activation Code',
            emailContent = emailContent
        } />

        <cfset email = objEmail.sendMandrillHTML(emailData) />
 --->
       <cfreturn true />

    </cffunction>
</cfcomponent>