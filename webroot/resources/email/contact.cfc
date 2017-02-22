<cfcomponent extends="taffy.core.resource" taffy:uri="/message/contact" hint="some hint about this resource">


	<cffunction name="post" access="public" output="false">
        <cfargument name="SendFrom" type="string" required="yes">
        <cfargument name="SendTo" type="string" required="yes">
        <cfargument name="ccTo" type="string" required="yes" default="">
        <cfargument name="Subject" type="string" required="yes">
        <cfargument name="emailContent" type="string" required="yes">
        <cfargument name="siteArea" type="string" required="yes">

        <cfquery datasource="startfly">
	    INSERT INTO contactSubmission (
	    siteArea,
	    dateSent,
	    name,
	    email,
	    message
	    ) VALUES (
	    '#arguments.siteArea#',
	    NOW(),
	    '#arguments.name#',
	    '#arguments.email#',
	    '#arguments.emailContent#'
	    )
        </cfquery>



        <cfset objEmail = createObject('component','/resources/private/email') />



        <cfset result = objEmail.SendMandrillHTML(arguments) />
				



		<cfreturn noData().withStatus(200) />
	</cffunction>

</cfcomponent>
