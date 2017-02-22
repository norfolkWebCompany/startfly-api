<cfcomponent>
    <cffunction name="send" access="public" returntype="any">
       <cfargument name="data" type="struct" required="true" /> 

        <cfset objTools = createObject('component','/resources/private/tools') />
        <cfset objDates = createObject('component','/resources/private/dates') />

        <cfset secureID = objTools.secureID() />
        <cfset rootDay = objTools.rootDay(now()) />
        <cfset dim = objDates.setDim({dateTime=now()}) />

        <cfquery datasource="startfly">
        INSERT INTO messages (
        sID,
        sentFrom,
        sentTo,
        type,
        uID,
        folder,
        subject,
        content,
        rootDay,
        dateID,
        timeID
        ) VALUES (
        '#secureID#',
        '#arguments.data.sentFrom#',
        '#arguments.data.sentTo#',
        '#arguments.data.type#',
        '#arguments.data.uID#',
        '#arguments.data.folder#',
        '#arguments.data.subject#',
        '#arguments.data.content#',
        #rootDay#,
        #dim.dateID#,
        #dim.timeID#
        )
        </cfquery>

       <cfreturn secureID />
    </cffunction>


    <cffunction name="SendMandrillHTML" access="public" returntype="any">
        <cfargument name="argCol" type="struct" required="yes">
        
        
        <!---API Key--->
        <cfset jsonStucture['form']['key'] = 'AO4s5MwqZNRJMXDqZa2ssg' />
    
    
        <!---Message Defaults--->
        <cfset jsonStucture['form']['message']['track_opens']			= true />
        <cfset jsonStucture['form']['message']['track_clicks']			= true />
        <cfset jsonStucture['form']['message']['auto_text']				= true />
        <cfset jsonStucture['form']['message']['url_strip_qs'] 			= true />
        <cfset jsonStucture['form']['message']['preserve_recipients']	= false />
        <cfset jsonStucture['form']['message']['bcc_address'] 			= ''/>
        <cfset jsonStucture['form']['message']['merge'] 				= false/>
        <!---Message Vars--->
        <cfset jsonStucture['form']['message']['from_email'] 			= arguments.argCol.SendFrom />
        <cfset jsonStucture['form']['message']['from_name'] 			= arguments.argCol.SendFrom />
        <cfset jsonStucture['form']['message']['subject'] 				= arguments.argCol.subject />
        <cfset jsonStucture['form']['message']['text'] 					= arguments.argCol.emailContent />
        <cfset jsonStucture['form']['message']['html'] 					= arguments.argCol.emailContent />
    
    
    
        <!---Assign to emails to array--->
		<cfset emailSet = arrayNew(1) />
        
        <cfloop from="1" to="#listlen(arguments.argCol.SendTo)#" index="i1">
            <cfset emailSet[i1]['email'] = listgetat(arguments.argCol.SendTo,i1) />
			<cfset emailSet[i1]["name"] = listgetat(arguments.argCol.SendTo,i1) />
        </cfloop>

		<cfset attachmentSet = arrayNew(1) />
        <cfset jsonStucture['form']['message']['to'] = emailSet />
        <cfset jsonStucture['form']['message']['attachments'] = attachmentSet />
        
        <cfset JSONmessage = serializeJSON(jsonStucture['form'],FALSE) />
		

        <cfhttp url="https://mandrillapp.com/api/1.0/messages/send.xml" method="post" result="httpresponse" timeout="60">
            <cfhttpparam type="body" name="message" value="#JSONmessage#" />
        </cfhttp>
		
        <cfreturn httpresponse />
    </cffunction>

</cfcomponent>