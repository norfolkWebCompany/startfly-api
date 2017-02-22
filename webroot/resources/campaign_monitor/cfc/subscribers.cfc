<cfcomponent extends="general" output="false">


	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>


	<cffunction name="add_subscriber" returntype="query" access="public" output="false"
    			hint="Adds a subscriber to an existing subscriber list, including custom field data if supplied. If the subscriber (email address) already exists, their name and any custom field values are updated with whatever is passed in. Existing custom field data is not cleared if new custom field values are not provided. Multi-Valued Select Many custom fields are set by providing multiple Custom Field array items with the same key. Date type custom fields may be cleared by passing in a value of '0000-00-00'.">
		<cfargument name="list_id" type="string" required="yes">
		<cfargument name="email_address" type="string" required="yes">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="resubscribe" type="boolean" required="no" default="false">
		<cfargument name="custom_fields" type="array" required="no" default="#ArrayNew(1)#">
        
        <cfset var request_url = "/subscribers/#arguments.list_id#.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        <cfset var xml_result = "">
        <cfset var custom_field = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <Subscriber>
                <EmailAddress>#trim(arguments.email_address)#</EmailAddress>
                <Name>#trim(arguments.name)#</Name>
                <cfif not ArrayIsEmpty(arguments.custom_fields)>
                    <CustomFields>
                        <cfloop array="#arguments.custom_fields#" index="custom_field">
                            <CustomField>
                                <Key>#trim(custom_field.key)#</Key>
                                <Value>#trim(custom_field.value)#</Value>
                            </CustomField>
                        </cfloop>
                    </CustomFields>
                </cfif>
                <Resubscribe>#trim(arguments.resubscribe)#</Resubscribe>
            </Subscriber>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("SubscriberEmail")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "SubscriberEmail", xml_result.string.XMLText)>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="update_subscriber" returntype="query" access="public" output="false"
    			hint="Updates any aspect of an existing subscriber, including email address, name, and custom field data if supplied. Any missing values will remain unchanged. Multi-Valued Select Many custom fields are set by providing multiple Custom Field array items with the same key. Date type custom fields may be cleared by passing in a value of '0000-00-00'. Note: the email value in the query string is the old email address. Use the EmailAddress property in the request body to change the email address. The update will apply whether the subscriber is active or inactive, although if the subscriber does not exist, a new one will not be added.">
		<cfargument name="list_id" type="string" required="yes">
		<cfargument name="old_email_address" type="string" required="yes">
		<cfargument name="new_email_address" type="string" required="yes">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="resubscribe" type="boolean" required="no" default="false">
		<cfargument name="custom_fields" type="array" required="no" default="#ArrayNew(1)#">
        
        <cfset var request_url = "/subscribers/#arguments.list_id#.xml?email=#URLEncodedFormat(trim(arguments.old_email_address))#">
        <cfset var request_method = "put">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        <cfset var custom_field = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <Subscriber>
                <EmailAddress>#trim(arguments.new_email_address)#</EmailAddress>
                <Name>#trim(arguments.name)#</Name>
                <cfif not ArrayIsEmpty(arguments.custom_fields)>
                    <CustomFields>
                        <cfloop array="#arguments.custom_fields#" index="custom_field">
                            <CustomField>
                                <Key>#trim(custom_field.key)#</Key>
                                <Value>#trim(custom_field.value)#</Value>
                            </CustomField>
                        </cfloop>
                    </CustomFields>
                </cfif>
                <Resubscribe>#trim(arguments.resubscribe)#</Resubscribe>
            </Subscriber>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>       
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="import_subscribers" returntype="query" access="public" output="false"
    			hint="Allows you to add many subscribers to a subscriber list in one API request, including custom field data if supplied. If a subscriber (email address) already exists, their name and any custom field values are updated with whatever is passed in.  Existing custom field data is not cleared if new custom field values are not provided. Multi-Valued Select Many custom fields are set by providing multiple Custom Field array items with the same key. Date type custom fields may be cleared by passing in a value of '0000-00-00'.  New subscribers only will be sent the follow-up email as configured in the list settings. If the list has been set as double opt-in, they will be sent the verification email, otherwise they will be sent the confirmation email you have set up for the list being subscribed to.  Autoresponder emails that are based on the subscription date will not be sent for subscribers imported with this method.  Please note: If any subscribers are in an inactive state or have previously been unsubscribed and you specify the Resubscribe input value as true, they will be re-added to the active list. Therefore, this method should be used with caution and only where suitable. If Resubscribe is specified as false, subscribers will not be re-added to the active list.">
		<cfargument name="list_id" type="string" required="yes">
		<cfargument name="subscribers" type="array" required="yes">
		<cfargument name="resubscribe" type="string" required="no" default="false">
        
        <!---
			
			The 'subscribers' argument of this method takes an array of subscriber structures.
			I realise that this could have been a query, xml, json or a number of other data formats,
			but I did it this way so feel free to edit if you disagree :)
			
			Here's a lengthy example of how you could create this:
			
			<cfset my_subscribers = ArrayNew(1)>

			<cfset ArrayAppend(my_subscribers, StructNew())>
			<cfset my_subscribers[ArrayLen(my_subscribers)].email_address = 'example1@example.com'>
			<cfset my_subscribers[ArrayLen(my_subscribers)].name = 'Joe Bloggs'>
			
			<cfset ArrayAppend(my_subscribers, StructNew())>
			<cfset my_subscribers[ArrayLen(my_subscribers)].email_address = 'example2@hello.com'>
			<cfset my_subscribers[ArrayLen(my_subscribers)].name = 'Rupert Murdoch'>
			<cfset my_subscribers[ArrayLen(my_subscribers)].custom_fields = ArrayNew(1)>
			<cfset my_subscribers[ArrayLen(my_subscribers)].custom_fields[1] = StructNew()>
			<cfset my_subscribers[ArrayLen(my_subscribers)].custom_fields[1].key = "website">
			<cfset my_subscribers[ArrayLen(my_subscribers)].custom_fields[1].value = "http://www.thesun.co.uk">
			<cfset my_subscribers[ArrayLen(my_subscribers)].custom_fields[2] = StructNew()>
			<cfset my_subscribers[ArrayLen(my_subscribers)].custom_fields[2].key = "interests">
			<cfset my_subscribers[ArrayLen(my_subscribers)].custom_fields[2].value = "Global domination">
			
			<cfset subscribers = CreateObject("component", "cfc.subscribers").init()>
			
			<cfset subscribers.import_subscribers('123123xyzxyz123123xyzxyz', my_subscribers)>
			
			^ replace '123123xyzxyz123123xyzxyz' with your list ID.
			
		--->
        
        <cfset var request_url = "/subscribers/#arguments.list_id#/import.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        <cfset var xml_result = "">
        <cfset var xml_result_success = "">
        <cfset var custom_field = "">
        <cfset var item = "">
        <cfset var subscriber = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <AddSubscribers>
                <Subscribers>
                	<cfloop array="#subscribers#" index="subscriber">
                        <Subscriber>
                            <EmailAddress>#trim(subscriber.email_address)#</EmailAddress>
                            <Name>#trim(subscriber.name)#</Name>
                            <cfif IsDefined("subscriber.custom_fields") AND (not ArrayIsEmpty(subscriber.custom_fields))>
                                <CustomFields>
                                    <cfloop array="#subscriber.custom_fields#" index="custom_field">
                                        <CustomField>
                                            <Key>#trim(custom_field.key)#</Key>
                                            <Value>#trim(custom_field.value)#</Value>
                                        </CustomField>
                                    </cfloop>
                                </CustomFields>
                            </cfif>
                        </Subscriber>
                    </cfloop>
                </Subscribers>
                <Resubscribe>#trim(arguments.resubscribe)#</Resubscribe>
            </AddSubscribers>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)> 
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset xml_result_success = XMLSearch(xml_result, '//BulkImportResults')>
        
        <cfif not ArrayIsEmpty(xml_result_success)>
        
			<cfset result_query = QueryNew("TotalUniqueEmailsSubmitted,TotalExistingSubscribers,
										   TotalNewSubscribers,DuplicateEmailsInSubmission")>
            
            <cfloop array="#xml_result_success#" index="item">
                <cfset QueryAddRow(result_query)>
                <cfset QuerySetCell(result_query, "TotalUniqueEmailsSubmitted", item.TotalUniqueEmailsSubmitted.XMLText)>
                <cfset QuerySetCell(result_query, "TotalExistingSubscribers", item.TotalExistingSubscribers.XMLText)>
                <cfset QuerySetCell(result_query, "TotalNewSubscribers", item.TotalNewSubscribers.XMLText)>
                <cfset QuerySetCell(result_query, "DuplicateEmailsInSubmission", item.DuplicateEmailsInSubmission.XMLText)>
        	</cfloop>
            
		<cfelse>
        
        	<cfset xml_result = XMLSearch(xml_result, '//ResultData')>
        
			<cfset result_query = QueryNew("TotalUniqueEmailsSubmitted,TotalExistingSubscribers,
										   TotalNewSubscribers,DuplicateEmailsInSubmission,FailureDetails")>
            
            <cfloop array="#xml_result#" index="item">
                <cfset QueryAddRow(result_query)>
                <cfset QuerySetCell(result_query, "TotalUniqueEmailsSubmitted", item.TotalUniqueEmailsSubmitted.XMLText)>
                <cfset QuerySetCell(result_query, "TotalExistingSubscribers", item.TotalExistingSubscribers.XMLText)>
                <cfset QuerySetCell(result_query, "TotalNewSubscribers", item.TotalNewSubscribers.XMLText)>
                <cfset QuerySetCell(result_query, "DuplicateEmailsInSubmission", item.DuplicateEmailsInSubmission.XMLText)>
            	<cfset QuerySetCell(result_query, "FailureDetails", QueryNew("EmailAddress,Code,Message"))>
            
                <cfloop array="#item.FailureDetails.XMLChildren#" index="subscriber">
                    <cfset QueryAddRow(result_query["FailureDetails"][result_query.recordcount])>
                    <cfset QuerySetCell(result_query["FailureDetails"][result_query.recordcount], "EmailAddress", subscriber.EmailAddress.XMLText)>
                    <cfset QuerySetCell(result_query["FailureDetails"][result_query.recordcount], "Code", subscriber.Code.XMLText)>
                    <cfset QuerySetCell(result_query["FailureDetails"][result_query.recordcount], "Message", subscriber.Message.XMLText)>
                </cfloop>
            </cfloop>
        
        </cfif>
        
        <cfreturn result_query>
        
	</cffunction>
    

	<cffunction name="subscriber_details" returntype="query" access="public" output="false"
    			hint="Retrieves a subscriber's details including their email address, name, active/inactive state, and any custom field data.">
		<cfargument name="list_id" type="string" required="yes">
		<cfargument name="email_address" type="string" required="yes">
        
        <cfset var request_url = "/subscribers/#arguments.list_id#.xml?email=#URLEncodedFormat(trim(arguments.email_address))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var result_query = "">
        <cfset var xml_result = "">
        <cfset var custom_field = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)> 
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset xml_result = XMLSearch(xml_result, '//Subscriber')>
        
		<cfset result_query = QueryNew("EmailAddress,Name,Date,State,CustomFields")>
        
        <cfloop array="#xml_result#" index="item">
            <cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "EmailAddress", item.EmailAddress.XMLText)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
            <cfset QuerySetCell(result_query, "Date", item.Date.XMLText)>
            <cfset QuerySetCell(result_query, "State", item.State.XMLText)>
            <cfset QuerySetCell(result_query, "ReadsEmailWith", item.ReadsEmailWith.XMLText)>
            <cfset QuerySetCell(result_query, "CustomFields", QueryNew("Key,Value"))>
        	<cfif not ArrayIsEmpty(item.CustomFields.XMLChildren)>
                <cfloop array="#item.CustomFields.XMLChildren#" index="custom_field">
                    <cfset QueryAddRow(result_query["CustomFields"][result_query.recordcount])>
                    <cfset QuerySetCell(result_query["CustomFields"][result_query.recordcount], "Key", custom_field.Key.XMLText)>
                    <cfset QuerySetCell(result_query["CustomFields"][result_query.recordcount], "Value", custom_field.Value.XMLText)>
                </cfloop>
            </cfif>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>
    

	<cffunction name="subscriber_history" returntype="query" access="public" output="false"
    			hint="Retrieves a list of campaigns and or autoresponder emails, in response to which a subscriber has made some trackable action. For each campaign or autoresponder email, all actions are recorded, including the event type, the date and the IP address from which the event occurred.">
		<cfargument name="list_id" type="string" required="yes">
		<cfargument name="email_address" type="string" required="yes">
        
        <cfset var request_url = "/subscribers/#arguments.list_id#/history.xml?email=#URLEncodedFormat(trim(arguments.email_address))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var result_query = "">
        <cfset var xml_result = "">
        <cfset var item = "">
        <cfset var action = "">
        
        <cfset response = http_request(request_url, request_method)> 
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset xml_result = XMLSearch(xml_result, '//Email')>
        
		<cfset result_query = QueryNew("ID,Type,Name,Actions")>
        
        <cfloop array="#xml_result#" index="item">
            <cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "ID", item.ID.XMLText)>
            <cfset QuerySetCell(result_query, "Type", item.Type.XMLText)>
            <cfset QuerySetCell(result_query, "Name", item.Name.XMLText)>
            <cfset QuerySetCell(result_query, "Actions", QueryNew("Event,Date,IPAddress,Detail"))>
        
            <cfloop array="#item.Actions.XMLChildren#" index="action">
                <cfset QueryAddRow(result_query["Actions"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Actions"][result_query.recordcount], "Event", action.Event.XMLText)>
                <cfset QuerySetCell(result_query["Actions"][result_query.recordcount], "Date", action.Date.XMLText)>
                <cfset QuerySetCell(result_query["Actions"][result_query.recordcount], "IPAddress", action.IPAddress.XMLText)>
                <cfset QuerySetCell(result_query["Actions"][result_query.recordcount], "Detail", action.Detail.XMLText)>
            </cfloop>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>
    

	<cffunction name="unsubscribe_subscriber" returntype="query" access="public" output="false"
    			hint="Changes the status of an Active Subscriber to an Unsubscribed Subscriber who will no longer receive campaigns sent to the subscriber list to which they belong. If the list is set to add unsubscribing subscribers to the suppression list, then the subscriber’s email address will also be added to the suppression list.">
		<cfargument name="list_id" type="string" required="yes">
		<cfargument name="email_address" type="string" required="yes">
        
        <cfset var request_url = "/subscribers/#arguments.list_id#/unsubscribe.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <Subscriber>
            	<EmailAddress>#trim(arguments.email_address)#</EmailAddress>
            </Subscriber>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>   
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>
    

	<cffunction name="delete_subscriber" returntype="query" access="public" output="false"
    			hint="Changes the status of an Active Subscriber to a Deleted Subscriber who will no longer receive campaigns sent to the subscriber list to which they belong. This will not result in the subscriber’s email address being added to the suppression list.">
		<cfargument name="list_id" type="string" required="yes">
		<cfargument name="email_address" type="string" required="yes">
        
        <cfset var request_url = "/subscribers/#arguments.list_id#.xml?email=#trim(arguments.email_address)#">
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