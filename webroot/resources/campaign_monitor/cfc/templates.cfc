<cfcomponent extends="general" output="false">


	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>


	<cffunction name="get_template" returntype="query" access="public" output="false"
    			hint="Returns all the basic details for a specific template including the name, ID, preview URL and screenshot URL.">
        <cfargument name="template_id" type="string" required="yes">
        
        <cfset var request_url = "/templates/#arguments.template_id#.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var result_query = "">
        <cfset var xml_result = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        <cfset xml_result = XMLSearch(xml_result, '//Template')>
        
        <cfset result_query = QueryNew("Name,PreviewURL,ScreenshotURL,TemplateID")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
            <cfset QuerySetCell(result_query, "PreviewURL", item.PreviewURL.XMLText)>
            <cfset QuerySetCell(result_query, "ScreenshotURL", item.ScreenshotURL.XMLText)>
            <cfset QuerySetCell(result_query, "TemplateID", item.TemplateID.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="create_template" returntype="query" access="public" output="false"
    			hint="Adds a new template for an existing client by providing the name of the template and URLs for the HTML file and a zip of all other files.">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="name" type="string" required="yes">
        <cfargument name="html_page_url" type="string" required="yes">
        <cfargument name="zip_file_url" type="string" required="yes">
        
        <cfset var request_url = "/templates/#arguments.client_id#.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        <cfset var xml_result = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
                <Template>
                    <Name>#trim(arguments.name)#</Name>
                    <HtmlPageURL>#trim(arguments.html_page_url)#</HtmlPageURL>
                    <ZipFileURL>#trim(arguments.zip_file_url)#</ZipFileURL>
                </Template>
            </cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>      
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("TemplateID")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "TemplateID", xml_result.string.XMLText)>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="update_template" returntype="query" access="public" output="false"
    			hint="Updates an existing template for a client. You can update the name of the template and URLs for the HTML file and zip file.">
        <cfargument name="template_id" type="string" required="yes">
        <cfargument name="name" type="string" required="yes">
        <cfargument name="html_page_url" type="string" required="yes">
        <cfargument name="zip_file_url" type="string" required="yes">
        
        <cfset var request_url = "/templates/#arguments.template_id#.xml">
        <cfset var request_method = "put">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
                <Template>
                    <Name>#trim(arguments.name)#</Name>
                    <HtmlPageURL>#trim(arguments.html_page_url)#</HtmlPageURL>
                    <ZipFileURL>#trim(arguments.zip_file_url)#</ZipFileURL>
                </Template>
            </cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>      
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="delete_template" returntype="query" access="public" output="false"
    			hint="Deletes an existing template based on the template ID.">
        <cfargument name="template_id" type="string" required="yes">
        
        <cfset var request_url = "/templates/#arguments.template_id#.xml">
        <cfset var request_method = "delete">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>      
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>
    
    
</cfcomponent>