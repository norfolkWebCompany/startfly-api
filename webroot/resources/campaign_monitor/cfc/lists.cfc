<cfcomponent extends="general" output="false">


	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>


	<cffunction name="create_list" returntype="query" access="public" output="false"
    			hint="Creates a new list into which subscribers can be added or imported. Set the list title, landing pages and confirmation setting.">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="title" type="string" required="yes">
        <cfargument name="confirmed_opt_in" type="string" required="no" default="true">
        <cfargument name="confirmation_success_page" type="string" required="no" default="">
        <cfargument name="unsubscribe_page" type="string" required="no" default="">
        <cfargument name="unsubscribe_setting" type="string" required="no" default="">
        
        <cfset var request_url = "/lists/#arguments.client_id#.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <List> 
                <ConfirmedOptIn>#trim(arguments.confirmed_opt_in)#</ConfirmedOptIn>
                <ConfirmationSuccessPage>#trim(arguments.confirmation_success_page)#</ConfirmationSuccessPage>
                <Title>#trim(arguments.title)#</Title>
                <UnsubscribePage>#trim(arguments.unsubscribe_page)#</UnsubscribePage>
                <UnsubscribeSetting>#trim(arguments.unsubscribe_setting)#</UnsubscribeSetting>
            </List>
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


	<cffunction name="list_details" returntype="query" access="public" output="false"
    			hint="A basic summary for each list in your account including the name, ID, type of list (single or confirmed opt-in) and any custom unsubscribe and confirmation URL you've specified.">
        <cfargument name="list_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#.xml">
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
        
        <cfset result_query = QueryNew("ConfirmationSuccessPage,ConfirmedOptIn,ListID,Title,UnsubscribePage,UnsubscribeSetting")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "ConfirmationSuccessPage", item.ConfirmationSuccessPage.XMLText)>
            <cfset QuerySetCell(result_query, "ConfirmedOptIn", item.ConfirmedOptIn.XMLText)>
            <cfset QuerySetCell(result_query, "ListID", item.ListID.XMLText)>
            <cfset QuerySetCell(result_query, "Title", item.Title.XMLText)>
            <cfset QuerySetCell(result_query, "UnsubscribePage", item.UnsubscribePage.XMLText)>
            <cfset QuerySetCell(result_query, "UnsubscribeSetting", item.UnsubscribeSetting.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="list_stats" returntype="query" access="public" output="false"
    			hint="Comprehensive summary statistics for each list in your account including subscriber counts across active, unsubscribed, deleted and bounced as well as time-based data like new subscribers today, yesterday, this week, month and year.">
        <cfargument name="list_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/stats.xml">
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
        
        <cfset result_query = QueryNew("BouncesThisMonth,BouncesThisWeek,BouncesThisYear,BouncesToday,
									   BouncesYesterday,DeletedThisMonth,DeletedThisWeek,DeletedThisYear,
									   DeletedToday,DeletedYesterday,NewActiveSubscribersThisMonth,
									   NewActiveSubscribersThisWeek,NewActiveSubscribersThisYear,
									   NewActiveSubscribersToday,NewActiveSubscribersYesterday,
									   TotalActiveSubscribers,TotalBounces,TotalDeleted,TotalUnsubscribes,
									   UnsubscribesThisMonth,UnsubscribesThisWeek,UnsubscribesThisYear,
									   UnsubscribesToday,UnsubscribesYesterday")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "BouncesThisMonth", item.BouncesThisMonth.XMLText)>
			<cfset QuerySetCell(result_query, "BouncesThisWeek", item.BouncesThisWeek.XMLText)>
            <cfset QuerySetCell(result_query, "BouncesThisYear", item.BouncesThisYear.XMLText)>
            <cfset QuerySetCell(result_query, "BouncesToday", item.BouncesToday.XMLText)>
            <cfset QuerySetCell(result_query, "BouncesYesterday", item.BouncesYesterday.XMLText)>
            <cfset QuerySetCell(result_query, "DeletedThisMonth", item.DeletedThisMonth.XMLText)>
            <cfset QuerySetCell(result_query, "DeletedThisWeek", item.DeletedThisWeek.XMLText)>
            <cfset QuerySetCell(result_query, "DeletedThisYear", item.DeletedThisYear.XMLText)>
            <cfset QuerySetCell(result_query, "DeletedToday", item.DeletedToday.XMLText)>
            <cfset QuerySetCell(result_query, "DeletedYesterday", item.DeletedYesterday.XMLText)>
            <cfset QuerySetCell(result_query, "NewActiveSubscribersThisMonth", item.NewActiveSubscribersThisMonth.XMLText)>
            <cfset QuerySetCell(result_query, "NewActiveSubscribersThisWeek", item.NewActiveSubscribersThisWeek.XMLText)>
            <cfset QuerySetCell(result_query, "NewActiveSubscribersThisYear", item.NewActiveSubscribersThisYear.XMLText)>
            <cfset QuerySetCell(result_query, "NewActiveSubscribersToday", item.NewActiveSubscribersToday.XMLText)>
            <cfset QuerySetCell(result_query, "NewActiveSubscribersYesterday", item.NewActiveSubscribersYesterday.XMLText)>
            <cfset QuerySetCell(result_query, "TotalActiveSubscribers", item.TotalActiveSubscribers.XMLText)>
            <cfset QuerySetCell(result_query, "TotalBounces", item.TotalBounces.XMLText)>
            <cfset QuerySetCell(result_query, "TotalDeleted", item.TotalDeleted.XMLText)>
            <cfset QuerySetCell(result_query, "TotalUnsubscribes", item.TotalUnsubscribes.XMLText)>
            <cfset QuerySetCell(result_query, "UnsubscribesThisMonth", item.UnsubscribesThisMonth.XMLText)>
            <cfset QuerySetCell(result_query, "UnsubscribesThisWeek", item.UnsubscribesThisWeek.XMLText)>
            <cfset QuerySetCell(result_query, "UnsubscribesThisYear", item.UnsubscribesThisYear.XMLText)>
            <cfset QuerySetCell(result_query, "UnsubscribesToday", item.UnsubscribesToday.XMLText)>
            <cfset QuerySetCell(result_query, "UnsubscribesYesterday", item.UnsubscribesYesterday.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="list_custom_fields" returntype="query" access="public" output="false"
    			hint="Returns all the custom fields for a given list in your account, including the type of field and any additional field options you've specified.">
        <cfargument name="list_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/customfields.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var options = "">
        <cfset var item = "">
        <cfset var field_option = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset xml_result = XMLSearch(xml_result, '//CustomField')>
        
        <cfset result_query = QueryNew("DataType,FieldName,FieldOptions,Key")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "DataType", item.DataType.XMLText)>
			<cfset QuerySetCell(result_query, "FieldName", item.FieldName.XMLText)>
            <cfset options = "">
            <cfif not ArrayIsEmpty(item.FieldOptions.XMLChildren)>
                <cfloop array="#item.FieldOptions.XMLChildren#" index="field_option">
                	<cfset options = options & field_option.XMLText & ",">
                </cfloop>
                <cfset options = Left(options, Len(options)-1)>
            </cfif>
            <cfset QuerySetCell(result_query, "FieldOptions", options)>
            <cfset QuerySetCell(result_query, "Key", item.Key.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="list_segments" returntype="query" access="public" output="false"
    			hint="Returns all the segments you have created for this list including the name, segment and list ID. You can also create your own segments and manage your own segment rules via the API.">
        <cfargument name="list_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/segments.xml">
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


	<cffunction name="active_subscribers" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all the active subscribers for a given list. This includes their email address, name, date subscribed and any custom field data. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/lists/#arguments.list_id#/active.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("CustomFields,Date,EmailAddress,Name,State"))>
            
        
            <cfloop array="#item.Results.XMLChildren#" index="subscriber">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", subscriber.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", subscriber.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Name", subscriber.Name.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "State", subscriber.State.XMLText)>
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


	<cffunction name="unconfirmed_subscribers" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all the unconfirmed subscribers (those who have subscribed to a confirmed-opt-in list, but have not confirmed their subscription) for a given list. This includes their email address, name, date subscribed (in the client's timezone), and any custom field data. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/lists/#arguments.list_id#/unconfirmed.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("CustomFields,Date,EmailAddress,Name,State"))>
            
        
            <cfloop array="#item.Results.XMLChildren#" index="subscriber">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", subscriber.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", subscriber.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Name", subscriber.Name.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "State", subscriber.State.XMLText)>
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


	<cffunction name="unsubscribed_subscribers" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all the unsubscribed subscribers for a given list. This includes their email address, name, date unsubscribed and any custom field data. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/lists/#arguments.list_id#/unsubscribed.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("CustomFields,Date,EmailAddress,Name,State"))>
            
        
            <cfloop array="#item.Results.XMLChildren#" index="subscriber">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", subscriber.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", subscriber.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Name", subscriber.Name.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "State", subscriber.State.XMLText)>
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


	<cffunction name="bounced_subscribers" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all the bounced subscribers for a given list. This includes their email address, name, date bounced and any custom field data. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/lists/#arguments.list_id#/bounced.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("CustomFields,Date,EmailAddress,Name,State"))>
            
        
            <cfloop array="#item.Results.XMLChildren#" index="subscriber">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", subscriber.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", subscriber.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Name", subscriber.Name.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "State", subscriber.State.XMLText)>
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


	<cffunction name="deleted_subscribers" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all the deleted subscribers for a given list. This includes their email address, name, date deleted (in the client's timezone) and any custom field data. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/lists/#arguments.list_id#/deleted.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("CustomFields,Date,EmailAddress,Name,State"))>
            
        
            <cfloop array="#item.Results.XMLChildren#" index="subscriber">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", subscriber.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", subscriber.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Name", subscriber.Name.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "State", subscriber.State.XMLText)>
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


	<cffunction name="update_list" returntype="query" access="public" output="false"
    			hint="Update the basic settings for any list in your account including the name, type and any subscribe and unsubscribe confirmation pages.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="title" type="string" required="yes">
        <cfargument name="confirmed_opt_in" type="string" required="no" default="true">
        <cfargument name="confirmation_success_page" type="string" required="no" default="">
        <cfargument name="unsubscribe_page" type="string" required="no" default="">
        
        <cfset var request_url = "/lists/#arguments.list_id#.xml">
        <cfset var request_method = "put">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <List> 
                <ConfirmedOptIn>#trim(arguments.confirmed_opt_in)#</ConfirmedOptIn>
                <ConfirmationSuccessPage>#trim(arguments.confirmation_success_page)#</ConfirmationSuccessPage>
                <Title>#trim(arguments.title)#</Title>
                <UnsubscribePage>#trim(arguments.unsubscribe_page)#</UnsubscribePage>
            </List>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="create_custom_field" returntype="query" access="public" output="false"
    			hint="Creates a new custom field for the provided list into which subscriber data can be added. Set the Custom Field name (from which the Key will be generated) and Data Type. Available Data Types are Text, Number, MultiSelectOne, MultiSelectMany, Date, Country and USState. For Multi-Valued fields (MultiSelectOne and MultiSelectMany) the possible options must also be provided. In the case of Country and USState fields the options will be automatically generated and made available when getting the lists custom fields.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="field_name" type="string" required="yes">
        <cfargument name="data_type" type="string" required="yes">
        <cfargument name="options" type="array" required="no" default="#ArrayNew(1)#">
        
        <cfset var request_url = "/lists/#arguments.list_id#/customfields.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var option = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <CustomField>
                <DataType>#trim(arguments.data_type)#</DataType>
                <FieldName>#trim(arguments.field_name)#</FieldName>
                <cfif not ArrayIsEmpty(arguments.options)>
                    <Options>
                        <cfloop array="#arguments.options#" index="option">
                            <Option>#trim(option)#</Option>
                        </cfloop>
                    </Options>
                </cfif>
            </CustomField>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("Key")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Key", xml_result.string.XMLText)>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="update_custom_field_options" returntype="query" access="public" output="false"
    			hint="Updates the available options for an existing Multi-Valued custom field (MultiSelectOne or MultiSelectMany). Existing options may be maintained or discarded based on the value of the KeepExistingOptions property.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="custom_field_key" type="string" required="yes">
        <cfargument name="keep_existing_options" type="string" required="no" default="true">
        <cfargument name="options" type="array" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/customfields/#URLEncodedFormat(trim(arguments.custom_field_key))#/options.xml">
        <cfset var request_method = "put">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var option = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <FieldOptions>
                <KeepExistingOptions>#trim(arguments.keep_existing_options)#</FieldName>
                <cfif not ArrayIsEmpty(arguments.options)>
                    <Options>
                        <cfloop array="#arguments.options#" index="option">
                            <Option>#trim(option)#</Option>
                        </cfloop>
                    </Options>
                </cfif>
            </FieldOptions>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="delete_custom_field" returntype="query" access="public" output="false"
    			hint="Deletes a specific custom field from a list.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="custom_field_key" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/customfields/#URLEncodedFormat(trim(arguments.custom_field_key))#.xml">
        <cfset var request_method = "delete">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="delete_list" returntype="query" access="public" output="false"
    			hint="Deletes a subscriber list from your account.">
        <cfargument name="list_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#.xml">
        <cfset var request_method = "delete">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="list_webhooks" returntype="query" access="public" output="false"
    			hint="Returns all the webhooks you have created for this list. For each webhook, the response includes its ID, URL, status, payload format and the events on which the webhook will be invoked.">
        <cfargument name="list_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/webhooks.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        <cfset var event = "">
        <cfset var events = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset xml_result = XMLSearch(xml_result, '//ListWebhook')>
        
        <cfset result_query = QueryNew("Events,PayloadFormat,Status,URL,WebhookID")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "WebhookID", item.WebhookID.XMLText)>
            <cfset QuerySetCell(result_query, "URL", item.URL.XMLText)>
            <cfset QuerySetCell(result_query, "Status", item.Status.XMLText)>
            <cfset QuerySetCell(result_query, "PayloadFormat", item.PayloadFormat.XMLText)>
            <cfset events = "">
            <cfif not ArrayIsEmpty(item.Events.XMLChildren)>
                <cfloop array="#item.Events.XMLChildren#" index="event">
                	<cfset events = events & event.XMLText & ",">
                </cfloop>
                <cfset events = Left(events, Len(events)-1)>
            </cfif>
            <cfset QuerySetCell(result_query, "Events", events)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="create_web_hook" returntype="query" access="public" output="false"
    			hint="Creates a new webhook for the provided list. Valid events are Subscribe, Deactivate, and Update. Valid payload formats are json, and xml.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="url" type="string" required="yes">
        <cfargument name="payload_format" type="string" required="yes">
        <cfargument name="events" type="array" required="no" default="#ArrayNew(1)#">
        
        <cfset var request_url = "/lists/#arguments.list_id#/webhooks.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var event = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <ListWebhook>
                <Url>#trim(arguments.url)#</Url>
                <PayloadFormat>#trim(arguments.payload_format)#</PayloadFormat>
                <cfif not ArrayIsEmpty(arguments.events)>
                    <Events>
                        <cfloop array="#arguments.events#" index="event">
                            <Event>#trim(event)#</Event>
                        </cfloop>
                    </Events>
                </cfif>
            </ListWebhook>
        	</cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("WebhookID")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "WebhookID", xml_result.string.XMLText)>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="test_webhook" returntype="query" access="public" output="false"
    			hint="Attempts to post a webhook payload to the endpoint specified for that webhook. If multiple events are subscribed to for that webhook, the payload will contain an example for each event as part of a batch response. Valid payload formats are json, and xml.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="webhook_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/webhooks/#arguments.webhook_id#/test.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="delete_webhook" returntype="query" access="public" output="false"
    			hint="Deletes a specific webhook associated with a list.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="webhook_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/webhooks/#arguments.webhook_id#.xml">
        <cfset var request_method = "delete">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="activate_webhook" returntype="query" access="public" output="false"
    			hint="Activate a webhook associated with a list.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="webhook_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/webhooks/#arguments.webhook_id#/activate.xml">
        <cfset var request_method = "put">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="deactivate_webhook" returntype="query" access="public" output="false"
    			hint="Deactivate a webhook associated with a list.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="webhook_id" type="string" required="yes">
        
        <cfset var request_url = "/lists/#arguments.list_id#/webhooks/#arguments.webhook_id#/deactivate.xml">
        <cfset var request_method = "put">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>



	<cffunction name="list_unconfirmed_subscribers" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all the unconfirmed subscribers (those who have subscribed to a confirmed-opt-in list, but have not confirmed their subscription) for a given list.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/lists/#arguments.list_id#/unconfirmed.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("CustomFields,Date,EmailAddress,ReadsEmailWith,Name,State"))>
            
        
            <cfloop array="#item.Results.XMLChildren#" index="subscriber">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", subscriber.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", subscriber.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Name", subscriber.Name.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "ReadsEmailWith", subscriber.ReadsEmailWith.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "State", subscriber.State.XMLText)>
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
    
    
</cfcomponent>