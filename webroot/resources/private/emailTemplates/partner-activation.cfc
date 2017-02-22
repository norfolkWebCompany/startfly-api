<cfcomponent>
    <cffunction name="send" access="public" returntype="any">
       <cfargument name="partnerID" type="numeric" required="true" /> 

        <cfset objTools = createObject('component','/resources/private/tools') />
        <cfset objEmail = createObject('component','/resources/private/email') />


        <cfquery name="thisPartner" datasource="startfly">
        SELECT firstname, surname, activationCode, email, sID 
        FROM partner 
        WHERE ID = #arguments.partnerID#
        </cfquery>


        <cfsavecontent variable="request_body">
            <cfoutput>
            <Subscriber>
                <EmailAddress>#trim(thisPartner.email)#</EmailAddress>
                <Name>#trim(thisPartner.firstname)# #trim(thisPartner.surname)#</Name>
            </Subscriber>
            </cfoutput>
        </cfsavecontent>

        <cfset thisURL = 'https://api.createsend.com/api/v3.1/subscribers/3fc677c18db54fb937874fcc9b8fc630.xml' />

        <cfhttp 
        url="#thisURL#" 
        method="post"
        username="72d3c8a2cbbf08caa7dab9a8f2174386" 
        password="">
            <cfhttpparam type="header" name="accept-encoding" value="no-compression" />
            <cfhttpparam type="xml" value="#trim(request_body)#" />
        </cfhttp>



        <cfsavecontent variable="emailContent">
        <cfoutput>
        <h2>Thank you for registering with Startfly</h2>
        <p>Your activation code is: #thisPartner.activationCode#</p>
        <p>Your account can be activated by clicking the following link</p>
        <p><a href="http://beta.startfly.co.uk/##/partner/registration/activate/#thisPartner.sID#">Activate Account</a></p>
        </cfoutput>
        </cfsavecontent>

        <cfset emailData = {
            sendTo = thisPartner.email,
            sendFrom = 'hello@startfly.co.uk',
            subject = 'Startfly Activation Code',
            emailContent = emailContent
        } />

        <cfset email = objEmail.sendMandrillHTML(emailData) />

       <cfreturn emailContent />

    </cffunction>
</cfcomponent>