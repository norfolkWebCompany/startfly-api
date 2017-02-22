<cfcomponent extends="taffy.core.resource" taffy:uri="/tracking" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="state" type="string" required="yes" />



		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset dataArray = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


        <cfset doGeo = 1 />

        <cfset ignoreList = 'mailgun,bingbot,majestic12,Google,Baiduspider,uptimebot' />

        <cfloop index="i1" list="#ignoreList#">
            <cfif listContainsNoCase(cgi.HTTP_USER_AGENT,i1) neq 0>
                <cfset doGeo = 0 />
            </cfif>
        </cfloop>


<!---
        <cfset scriptIgnoreList = ".cfc,include,assets,backoffice" />
        <cfloop index="i1" list="#scriptIgnoreList#">
            <cfif listContainsNoCase(arguments.data.SCRIPT_NAME,i1) neq 0>
                <cfset doGeo = 0 />
            </cfif>
        </cfloop>
--->




        <cfif doGeo is 1>

        	<cfquery name="getUser" datasource="startfly">
	        SELECT user 
	        FROM ipAddress 
	        WHERE ip = '#cgi.remote_addr#' 
	        LIMIT 1
        	</cfquery>

        	<cfif getUser.recordCount is 1>
	        	<cfset theUser = getUser.user />
	        <cfelse>
	        	<cfset theUser = '' />
        	</cfif>

            <cfquery datasource="startfly">
            INSERT INTO tracking (
            ipAddress,
            user,
            dateCreated,
            userAgent,
            scriptName
            ) VALUES (
            '#cgi.remote_addr#',
            '#theUser#',
            NOW(),
            '#cgi.HTTP_USER_AGENT#',
            '#arguments.state#'
            )
            </cfquery>


        </cfif>








		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>




</cfcomponent>
