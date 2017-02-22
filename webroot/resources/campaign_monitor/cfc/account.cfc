<cfcomponent extends="general" output="false">


	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>


	<cffunction name="get_api_key" returntype="query" access="public" output="false"
    			hint="Allows a client or designer to retrieve their API key, given their username, password, and site URL. This is the only API request which requires that you provide your username and password using HTTP basic authentication rather than passing in your API key as the username for basic authentication.">
		<cfargument name="site_url" type="string" required="yes">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
        
        <cfset var request_url = "/apikey.xml?siteurl=#URLEncodedFormat(trim(arguments.site_url))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method, "", arguments.username, arguments.password)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Result')>
        
        <cfset result_query = QueryNew("APIKey")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "APIKey", item.ApiKey.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="clients" returntype="query" access="public" output="false"
    			hint="Contains a list of all the clients in your account, including their name and ID.">
        
        <cfset var request_url = "/clients.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Client')>
        
        <cfset result_query = QueryNew("ClientID,Name")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "ClientID", item.ClientID.XMLText)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="valid_countries" returntype="query" access="public" output="false"
    			hint="Contains a list of all the valid countries accepted as input when a country is required, typically when creating a client.">
        
        <cfset var request_url = "/countries.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Country')>
        
        <cfset result_query = QueryNew("Country")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "Country", item.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="valid_timezones" returntype="query" access="public" output="false"
    			hint="Contains a list of all the valid timezones accepted as input when a timezone is required, typically when creating a client.">
        
        <cfset var request_url = "/timezones.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//TimeZone')>
        
        <cfset result_query = QueryNew("TimeZone")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "TimeZone", item.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="system_date" returntype="query" access="public" output="false"
    			hint="Contains the current date and time in your account's timezone. This is useful when, for example, you are syncing your Campaign Monitor lists with an external list, allowing you to accurately determine the time on our server when you carry out the synchronization.">
        
        <cfset var request_url = "/systemdate.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//SystemDate')>
        
        <cfset result_query = QueryNew("SystemDate")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "SystemDate", xml_result[1].XMLText)>
        
        <cfreturn result_query>
        
	</cffunction>
    
    
</cfcomponent>