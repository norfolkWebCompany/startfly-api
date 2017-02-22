<cfcomponent extends="taffy.core.resource" taffy:uri="/campaign/subscriber" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="emailAddress" type="string" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="listID" type="string" required="true" />
		<cfargument name="location" type="string" required="true" default="" />
		<cfargument name="businessType" type="string" required="true" default="" />

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


        <cfsavecontent variable="request_body">
        	<cfoutput>
            <Subscriber>
                <EmailAddress>#trim(arguments.emailAddress)#</EmailAddress>
                <Name>#trim(arguments.name)#</Name>
				<CustomFields>
				    <CustomField>
				        <Key>Location</Key>
				        <Value>#arguments.location#</Value>
				    </CustomField>
				    <CustomField>
				        <Key>BusinessType</Key>
				        <Value>#arguments.businessType#</Value>
				    </CustomField>
				</CustomFields>
            </Subscriber>
        	</cfoutput>
        </cfsavecontent>

        <cfset thisURL = 'https://api.createsend.com/api/v3.1/subscribers/' & arguments.listID & '.xml' />

		<cfhttp 
		url="#thisURL#" 
		method="post"
		username="72d3c8a2cbbf08caa7dab9a8f2174386" 
		password="">
            <cfhttpparam type="header" name="accept-encoding" value="no-compression" />
            <cfhttpparam type="xml" value="#trim(request_body)#" />
		</cfhttp>


		<cfset result.data = cfhttp.FileContent>



		
		<cfreturn representationOf(result).withStatus(200).withMime('text') />
	</cffunction>

</cfcomponent>
