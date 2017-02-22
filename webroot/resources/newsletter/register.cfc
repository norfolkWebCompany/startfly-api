<cfcomponent extends="taffy.core.resource" taffy:uri="/newsletter" hint="some hint about this resource">
    <cffunction name="post" access="public" output="false">
        <cfargument name="email" type="string" required="true" />

        <cfset objAccum = createObject('component','/resources/private/accum') />
        <cfset objTools = createObject('component','/resources/private/tools') />
        <cfset sTime = getTickCount() />

        <cfset result = {} />
        <cfset result['status'] = {} />
        <cfset result['data'] = {} />
        <cfset result['status']['statusCode'] = 200 />
        <cfset result['status']['message'] = 'OK' />

        <cfset objDates = createObject('component','/resources/private/dates') />

        <cfset secureID = objTools.secureID() />
        <cfset dim = objDates.setDim({dateTime=now()}) />

        <cfquery datasource="startfly">
        INSERT INTO newsletter (
        sID,
        email,
        dateID,
        timeID
        ) VALUES (
        '#secureID#',
        '#arguments.email#',
        #dim.dateID#,
        #dim.timeID#
        )
        </cfquery>

        <cfsavecontent variable="request_body">
            <cfoutput>
            <Subscriber>
                <EmailAddress>#trim(arguments.email)#</EmailAddress>
                <Name></Name>
            </Subscriber>
            </cfoutput>
        </cfsavecontent>


        <cfset thisURL = 'https://api.createsend.com/api/v3.1/subscribers/7f2522f121aa01daf92db707d7b853b3.xml' />

        <cfhttp 
        url="#thisURL#" 
        method="post"
        username="72d3c8a2cbbf08caa7dab9a8f2174386" 
        password="">
            <cfhttpparam type="header" name="accept-encoding" value="no-compression" />
            <cfhttpparam type="xml" value="#trim(request_body)#" />
        </cfhttp>


        <cfset result['data']['ID'] = secureID />
        <cfset result['data']['email'] = arguments.email />

        <cfset objTools.runtime('post', '/newsletter', (getTickCount() - sTime) ) />

        <cfreturn representationOf(result).withStatus(200) />
    </cffunction>
</cfcomponent>
