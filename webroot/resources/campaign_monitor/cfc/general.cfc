<cfcomponent output="false">
	
    <!--- ENTER YOUR PERSONAL API KEY HERE --->
    <cfset variables.api_key = "YOUR_API_KEY">
    <cfset variables.base_url = "https://api.createsend.com/api/v3">

	<cffunction name="http_request" returntype="string" access="private" output="false"
    			hint="Performs the HTTP request to the Campaign Monitor API">
		<cfargument name="url" type="string" required="yes">
		<cfargument name="method" type="string" required="yes">
		<cfargument name="body" type="string" required="no" default="">
		<cfargument name="username" type="string" required="no" default="#variables.api_key#">
		<cfargument name="password" type="string" required="no" default="na">
        
        <cfhttp 
            url="#variables.base_url##arguments.url#" 
            method="#arguments.method#"
            username="#arguments.username#" 
            password="#arguments.password#">
            <cfhttpparam type="header" name="accept-encoding" value="no-compression" />
            <cfhttpparam type="xml" value="#trim(arguments.body)#" />
        </cfhttp>
        
        <cfif cfhttp.responseheader.status_code neq 200 AND cfhttp.responseheader.status_code neq 201>
        	<cfset handle_error(cfhttp.FileContent)>
        </cfif>
        
        <cfreturn cfhttp.FileContent>
        
	</cffunction>


	<cffunction name="handle_error" access="private" output="false"
    			hint="Throws a Coldfusion error based on error codes returned from the Campaign Monitor API">
		<cfargument name="response" required="yes">
        
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfset xml_result = trim(arguments.response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '/Result')>
        
		<cfset result_query = QueryNew("Code,Message")>
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Code", xml_result[1].Code.XMLText)>
        <cfset QuerySetCell(result_query, "Message", xml_result[1].Message.XMLText)>
        
        <cfthrow errorcode="#xml_result[1].Code.XMLText#" message="#xml_result[1].Message.XMLText#">
        
	</cffunction>
    
    
</cfcomponent>