<cfcomponent extends="general" output="false">


	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>


	<cffunction name="create_client" returntype="query" access="public" output="false"
    			hint="Creates a new client in your account with basic contact information and no access to the application. Client access settings and billing are set once the client is created.">
        <cfargument name="company_name" type="string" required="yes">
        <cfargument name="contact_name" type="string" required="yes">
        <cfargument name="email_address" type="string" required="yes">
        <cfargument name="country" type="string" required="yes">
        <cfargument name="timezone" type="string" required="yes">
        
        <cfset var request_url = "/clients.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <Client> 
                <CompanyName>#trim(arguments.company_name)#</CompanyName>
                <ContactName>#trim(arguments.contact_name)#</ContactName>
                <EmailAddress>#trim(arguments.email_address)#</EmailAddress>
                <Country>#trim(arguments.country)#</Country>
                <TimeZone><![CDATA[#trim(arguments.timezone)#]]></TimeZone>
            </Client>
            </cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("ClientID")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "ClientID", xml_result.string.XMLText)>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="client_details" returntype="query" access="public" output="false"
    			hint="Get the complete details for a client including their API key, access level, contact details and billing settings.">
        <cfargument name="client_id" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#.xml">
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
        <cfset result_query = QueryNew("ApiKey,AccessDetails,BasicDetails,BillingDetails")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "ApiKey", item.ApiKey.XMLText)>
        	<cfset QuerySetCell(result_query, "AccessDetails", QueryNew("AccessLevel,Username"))>
			<cfset QueryAddRow(result_query["AccessDetails"][result_query.recordcount])>
            <cfset QuerySetCell(result_query["AccessDetails"][result_query.recordcount], "AccessLevel", item.AccessDetails.AccessLevel.XMLText)>
            <cfset QuerySetCell(result_query["AccessDetails"][result_query.recordcount], "Username", item.AccessDetails.Username.XMLText)>
            <cfset QuerySetCell(result_query, "BasicDetails", QueryNew("ClientID,CompanyName,ContactName,EmailAddress,Country,TimeZone"))>
            <cfset QueryAddRow(result_query["BasicDetails"][result_query.recordcount])>
            <cfset QuerySetCell(result_query["BasicDetails"][result_query.recordcount], "ClientID", item.BasicDetails.ClientID.XMLText)>
            <cfset QuerySetCell(result_query["BasicDetails"][result_query.recordcount], "CompanyName", item.BasicDetails.CompanyName.XMLText)>
            <cfset QuerySetCell(result_query["BasicDetails"][result_query.recordcount], "ContactName", item.BasicDetails.ContactName.XMLText)>
            <cfset QuerySetCell(result_query["BasicDetails"][result_query.recordcount], "EmailAddress", item.BasicDetails.EmailAddress.XMLText)>
            <cfset QuerySetCell(result_query["BasicDetails"][result_query.recordcount], "Country", item.BasicDetails.Country.XMLText)>
            <cfset QuerySetCell(result_query["BasicDetails"][result_query.recordcount], "TimeZone", item.BasicDetails.TimeZone.XMLText)>
            <cfif IsDefined("item.BillingDetails.CanPurchaseCredits.XMLText")>
				<cfset QuerySetCell(result_query, "BillingDetails", QueryNew("CanPurchaseCredits,MarkupOnDesignSpamTest,ClientPays,
																			 BaseRatePerRecipient,MarkupPerRecipient,MarkupOnDelivery,
																			 BaseDeliveryRate,Currency,BaseDesignSpamTestRate"))>
				<cfset QueryAddRow(result_query["BillingDetails"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "CanPurchaseCredits", item.BillingDetails.CanPurchaseCredits.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "MarkupOnDesignSpamTest", item.BillingDetails.MarkupOnDesignSpamTest.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "ClientPays", item.BillingDetails.ClientPays.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "BaseRatePerRecipient", item.BillingDetails.BaseRatePerRecipient.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "MarkupPerRecipient", item.BillingDetails.MarkupPerRecipient.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "MarkupOnDelivery", item.BillingDetails.MarkupOnDelivery.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "BaseDeliveryRate", item.BillingDetails.BaseDeliveryRate.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "Currency", item.BillingDetails.Currency.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "BaseDesignSpamTestRate", item.BillingDetails.BaseDesignSpamTestRate.XMLText)>
            <cfelse>
				<cfset QuerySetCell(result_query, "BillingDetails", QueryNew("ClientPays,Currency,CurrentMonthlyRate,CurrentTier,MarkupPercentage"))>
				<cfset QueryAddRow(result_query["BillingDetails"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "ClientPays", item.BillingDetails.ClientPays.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "Currency", item.BillingDetails.Currency.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "CurrentMonthlyRate", item.BillingDetails.CurrentMonthlyRate.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "CurrentTier", item.BillingDetails.CurrentTier.XMLText)>
                <cfset QuerySetCell(result_query["BillingDetails"][result_query.recordcount], "MarkupPercentage", item.BillingDetails.MarkupPercentage.XMLText)>
            </cfif>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="sent_campaigns" returntype="query" access="public" output="false"
    			hint="Returns a list of all sent campaigns for a client including the web version URL, ID, subject, name, date sent and the total number of recipients.">
        <cfargument name="client_id" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/campaigns.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Campaign')>
        
        <cfset result_query = QueryNew("WebVersionURL,CampaignID,Subject,Name,SentDate,TotalRecipients")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "WebVersionURL", item.WebVersionURL.XMLText)>
            <cfset QuerySetCell(result_query, "CampaignID", item.CampaignID.XMLText)>
            <cfset QuerySetCell(result_query, "Subject", item.Subject.XMLText)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
            <cfset QuerySetCell(result_query, "SentDate", item.SentDate.XMLText)>
            <cfset QuerySetCell(result_query, "TotalRecipients", item.TotalRecipients.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="scheduled_campaigns" returntype="query" access="public" output="false"
    			hint="Returns all currently scheduled campaigns for a client including the preview URL, ID, subject, name, date created, date scheduled, and the scheduled timezone.">
        <cfargument name="client_id" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/scheduled.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Campaign')>
        
        <cfset result_query = QueryNew("CampaignID,DateCreated,Name,PreviewURL,Subject,DateScheduled,ScheduledTimeZone")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "CampaignID", item.CampaignID.XMLText)>
            <cfset QuerySetCell(result_query, "DateCreated", item.DateCreated.XMLText)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
            <cfset QuerySetCell(result_query, "PreviewURL", item.PreviewURL.XMLText)>
            <cfset QuerySetCell(result_query, "Subject", item.Subject.XMLText)>
            <cfset QuerySetCell(result_query, "DateScheduled", item.DateScheduled.XMLText)>
            <cfset QuerySetCell(result_query, "ScheduledTimeZone", item.ScheduledTimeZone.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="draft_campaigns" returntype="query" access="public" output="false"
    			hint="Returns a list of all draft campaigns belonging to that client including the preview URL, ID, subject, name and the date the draft was created.">
        <cfargument name="client_id" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/drafts.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Campaign')>
        
        <cfset result_query = QueryNew("CampaignID,Name,Subject,DateCreated,PreviewURL")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "CampaignID", item.CampaignID.XMLText)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
            <cfset QuerySetCell(result_query, "Subject", item.Subject.XMLText)>
            <cfset QuerySetCell(result_query, "DateCreated", item.DateCreated.XMLText)>
            <cfset QuerySetCell(result_query, "PreviewURL", item.PreviewURL.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="subscriber_lists" returntype="query" access="public" output="false"
    			hint="Returns all the subscriber lists that belong to that client, including the list name and ID.">
        <cfargument name="client_id" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/lists.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//List')>
        
        <cfset result_query = QueryNew("ListID,Name")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "ListID", item.ListID.XMLText)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="segments" returntype="query" access="public" output="false"
    			hint="Contains a list of all list segments belonging to a particular client.">
        <cfargument name="client_id" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/segments.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Segment')>
        
        <cfset result_query = QueryNew("ListID,SegmentID,Title")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "ListID", item.ListID.XMLText)>
            <cfset QuerySetCell(result_query, "SegmentID", item.SegmentID.XMLText)>
            <cfset QuerySetCell(result_query, "Title", item.Title.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="suppression_list" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing the client's suppression list.">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/clients/#arguments.client_id#/suppressionlist.xml?page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        <cfset var subscriber = "">
        <cfset var custom_field = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset xml_result = XMLSearch(xml_result, '//PagedResult')>
        
        <cfset result_query = QueryNew("NumberOfPages,OrderDirection,PageNumber,
									   PageSize,RecordsOnThisPage,Results,
									   ResultsOrderedBy,TotalNumberOfRecords")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "NumberOfPages", item.NumberOfPages.XMLText)>
            <cfset QuerySetCell(result_query, "OrderDirection", item.OrderDirection.XMLText)>
            <cfset QuerySetCell(result_query, "PageNumber", item.PageNumber.XMLText)>
            <cfset QuerySetCell(result_query, "PageSize", item.PageSize.XMLText)>
            <cfset QuerySetCell(result_query, "Results", QueryNew("CustomFields,Date,EmailAddress,Name,State,SuppressionReason"))>
            
        
            <cfloop array="#item.Results.XMLChildren#" index="subscriber">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", subscriber.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", subscriber.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Name", subscriber.Name.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "State", subscriber.State.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "SuppressionReason", subscriber.SuppressionReason.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "CustomFields", QueryNew("Key,Value"))>
				<cfif not ArrayIsEmpty(subscriber.CustomFields.XMLChildren)>
                    <cfloop array="#subscriber.CustomFields.XMLChildren#" index="custom_field">
            			<cfset QueryAddRow(result_query["Results"][result_query.recordcount]["CustomFields"][result_query["Results"][result_query.recordcount].recordcount])>
						<cfset QuerySetCell(result_query["Results"][result_query.recordcount]["CustomFields"][result_query["Results"][result_query.recordcount].recordcount], "Key", custom_field.Key.XMLText)>
						<cfset QuerySetCell(result_query["Results"][result_query.recordcount]["CustomFields"][result_query["Results"][result_query.recordcount].recordcount], "Value", custom_field.Value.XMLText)>
                    </cfloop>
                </cfif>
            </cfloop>
            
            <cfset QuerySetCell(result_query, "ResultsOrderedBy", item.ResultsOrderedBy.XMLText)>
            <cfset QuerySetCell(result_query, "RecordsOnThisPage", item.RecordsOnThisPage.XMLText)>
            <cfset QuerySetCell(result_query, "TotalNumberOfRecords", item.TotalNumberOfRecords.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>
    


	<cffunction name="templates" returntype="query" access="public" output="false"
    			hint="Contains a list of the templates belonging to the client including the ID, name and a URL for a screenshot and HTML preview of the template.">
        <cfargument name="client_id" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/templates.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Template')>
        
        <cfset result_query = QueryNew("TemplateID,Name,PreviewURL,ScreenshotURL")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "TemplateID", item.TemplateID.XMLText)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
            <cfset QuerySetCell(result_query, "PreviewURL", item.PreviewURL.XMLText)>
            <cfset QuerySetCell(result_query, "ScreenshotURL", item.ScreenshotURL.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="set_basic_details" returntype="query" access="public" output="false"
    			hint="Update the basic account details for an existing client including their name, contact details and time zone.">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="company_name" type="string" required="yes">
        <cfargument name="contact_name" type="string" required="yes">
        <cfargument name="email_address" type="string" required="yes">
        <cfargument name="country" type="string" required="yes">
        <cfargument name="timezone" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/setbasics.xml">
        <cfset var request_method = "put">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <Client> 
                <CompanyName>#trim(arguments.company_name)#</CompanyName>
                <ContactName>#trim(arguments.contact_name)#</ContactName>
                <EmailAddress>#trim(arguments.email_address)#</EmailAddress>
                <Country>#trim(arguments.country)#</Country>
                <TimeZone>#trim(arguments.timezone)#</TimeZone>
            </Client>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>      
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="set_access_settings" returntype="query" access="public" output="false"
    			hint="Set the level of access this client should have for their account, ranging from no access at all right through to the ability send and pay for their own campaigns. The AccessLevel parameter is an integer which sets exactly which features that client can access. The AccessLevel can be updated for a client without changing the existing login details by omitting the Username/Password parameters from the request.">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="access_level" type="numeric" required="yes">
        <cfargument name="username" type="string" required="no" default="">
        <cfargument name="password" type="string" required="no" default="">
        
        <cfset var request_url = "/clients/#arguments.client_id#/setaccess.xml">
        <cfset var request_method = "put">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <AccessSettings>
                <cfif arguments.username neq "">
                	<Username>#trim(arguments.username)#</Username>
				</cfif>
                <cfif arguments.password neq "">
                	<Password>#trim(arguments.password)#</Password>
				</cfif>
                <AccessLevel>#trim(arguments.access_level)#</AccessLevel>
            </AccessSettings>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>      
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="set_payg_billing" returntype="query" access="public" output="false"
    			hint="Set if a client can pay for their own campaigns and design and spam tests using our PAYG billing. Set the mark-up percentage on each type of fee, and if the client can purchase their own email credits to access bulk discounts. Any specific markup values provided for the MarkupOnDelivery, MarkupPerRecipient or MarkupOnDesignSpamTest fields will override the percentage markup for those fields only, these fields are optional and should be omitted when not required. The MarkupOnDelivery and MarkupOnDesignSpamTest fields should be in the major unit for the specified currency (e.g '6.5' means '$6.50'), whilst the MarkupPerRecipient should be in the specified currencies minor unit (e.g '6.5' means '6.5 cents'). Note: Specific values can not be provided for the credit pricing tiers. Currencies supported are USD (US Dollars), GBP (Great Britain Pounds), EUR (Euros), CAD (Canadian Dollars), AUD (Australian Dollars), and NZD (New Zealand Dollars).">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="currency" type="string" required="yes">
        <cfargument name="can_purchase_credits" type="string" required="yes">
        <cfargument name="client_pays" type="string" required="yes">
        <cfargument name="markup_percentage" type="numeric" required="no" default="0">
        <cfargument name="markup_delivery" type="numeric" required="no" default="0">
        <cfargument name="markup_per_recipient" type="numeric" required="no" default="0">
        <cfargument name="markup_design_spam_test" type="numeric" required="no" default="0">
        
        <cfset var request_url = "/clients/#arguments.client_id#/setpaygbilling.xml">
        <cfset var request_method = "put">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <BillingOptions>
                <Currency>#trim(arguments.currency)#</Currency>
                <CanPurchaseCredits>#trim(arguments.can_purchase_credits)#</CanPurchaseCredits>
                <ClientPays>#trim(arguments.client_pays)#</ClientPays>
                <MarkupPercentage>#trim(arguments.markup_percentage)#</MarkupPercentage>
                <MarkupOnDelivery>#trim(arguments.markup_delivery)#</MarkupOnDelivery>
                <MarkupPerRecipient>#trim(arguments.markup_per_recipient)#</MarkupPerRecipient>
                <MarkupOnDesignSpamTest>#trim(arguments.markup_design_spam_test)#</MarkupOnDesignSpamTest>
            </BillingOptions>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>      
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="set_monthly_billing" returntype="query" access="public" output="false"
    			hint="Set if a client can pay for their own campaigns and design and spam tests using our monthly billing. Set the currency they should pay in plus mark-up percentage that will apply to the base prices at each pricing tier. Currencies supported are USD (US Dollars), GBP (Great Britain Pounds), EUR (Euros), CAD (Canadian Dollars), AUD (Australian Dollars), and NZD (New Zealand Dollars).">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="currency" type="string" required="yes">
        <cfargument name="client_pays" type="string" required="yes">
        <cfargument name="markup_percentage" type="numeric" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/setmonthlybilling.xml">
        <cfset var request_method = "put">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <BillingOptions>
                <Currency>#trim(arguments.currency)#</Currency>
                <ClientPays>#trim(arguments.client_pays)#</ClientPays>
                <MarkupPercentage>#trim(arguments.markup_percentage)#</MarkupPercentage>
            </BillingOptions>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>      
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="delete_client" returntype="query" access="public" output="false"
    			hint="Delete an existing client from your account.">
        <cfargument name="client_id" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#.xml">
        <cfset var request_method = "delete">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>      
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="unsuppress_email_address" returntype="query" access="public" output="false"
    			hint="Unsuppresses an email address by removing the email address from a client's suppression list.">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="email_address" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/unsuppress.xml?email=#arguments.email_address#">
        <cfset var request_method = "put">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>      
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>
    


	<cffunction name="lists_for_email_address" returntype="query" access="public" output="false"
    			hint="Returns all the subscriber lists across the client, to which an email address is subscribed.">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="email_address" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/listsforemail.xml?email=#arguments.email_address#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//List')>
        
        <cfset result_query = QueryNew("ListID,DateSubscriberAdded,ListName,SubscriberState")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "ListID", item.ListID.XMLText)>
            <cfset QuerySetCell(result_query, "DateSubscriberAdded", item.DateSubscriberAdded.XMLText)>
            <cfset QuerySetCell(result_query, "ListName", item.ListName.XMLText)>
            <cfset QuerySetCell(result_query, "SubscriberState", item.SubscriberState.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>
    


	<cffunction name="people_associated_with_client" returntype="query" access="public" output="false"
    			hint="Contains a list of all (active or invited) people associated with a particular client.">
        <cfargument name="client_id" type="string" required="yes">
        
        <cfset var request_url = "/clients/#arguments.client_id#/people.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Person')>
        
        <cfset result_query = QueryNew("EmailAddress,Name,AccessLevel,Status")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "EmailAddress", item.EmailAddress.XMLText)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
            <cfset QuerySetCell(result_query, "AccessLevel", item.AccessLevel.XMLText)>
            <cfset QuerySetCell(result_query, "Status", item.Status.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>
    
    
</cfcomponent>