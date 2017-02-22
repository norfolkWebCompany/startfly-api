<cfcomponent extends="general" output="false">


	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>


	<cffunction name="create_draft_campaign" returntype="query" access="public" output="false" 
    			hint="Creates (but does not send) a draft campaign ready to be tested as a preview or sent. Set the basic campaign information (name, subject, from name and from email), the URL's of the HTML and plain text content plus the lists and/or segments you'd like it to be eventually sent to. We'll automatically move all CSS inline for the HTML component.">
        <cfargument name="client_id" type="string" required="yes">
        <cfargument name="campaign_name" type="string" required="yes">
        <cfargument name="subject" type="string" required="yes">
        <cfargument name="from_name" type="string" required="yes">
        <cfargument name="from_email" type="string" required="yes">
        <cfargument name="replyto_email" type="string" required="yes">
        <cfargument name="html_url" type="string" required="yes">
        <cfargument name="text_url" type="string" required="no" default="">
        <cfargument name="list_ids" type="array" required="no" default="#ArrayNew(1)#">
        <cfargument name="segment_ids" type="array" required="no" default="#ArrayNew(1)#">
        
        <cfset var request_url = "/campaigns/#arguments.client_id#.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var list_id = "">
        <cfset var segment_id = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <Campaign>
                <Name>#trim(arguments.campaign_name)#</Name>
                <Subject>#trim(arguments.subject)#</Subject>
                <FromName>#trim(arguments.from_name)#</FromName>
                <FromEmail>#trim(arguments.from_email)#</FromEmail>
                <ReplyTo>#trim(arguments.replyto_email)#</ReplyTo>
                <HtmlUrl>#trim(arguments.html_url)#</HtmlUrl>
                <cfif arguments.text_url neq "">
                	<TextUrl>#trim(arguments.text_url)#</TextUrl>
				</cfif>
                <cfif not ArrayIsEmpty(arguments.list_ids)>
                    <ListIDs>
                        <cfloop array="#arguments.list_ids#" index="list_id">
                            <ListID>#trim(list_id)#</ListID>
                        </cfloop>
                    </ListIDs>
                </cfif>
                <cfif not ArrayIsEmpty(arguments.segment_ids)>
                    <SegmentIDs>
                        <cfloop array="#arguments.segment_ids#" index="segment_id">
                            <SegmentID>#trim(segment_id)#</SegmentID>
                        </cfloop>
                    </SegmentIDs>
                </cfif>
            </Campaign>
            </cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>        
        
        <cfset result_query = QueryNew("CampaignID")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "CampaignID", xml_result.string.XMLText)>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="send_draft_campaign" returntype="query" access="public" output="false"
    			hint="Schedules an existing draft campaign for sending either immediately or a custom date and time in the future. For campaigns with more than 5 recipients, you must have sufficient email credits, a saved credit card or an active monthly billed account.">
        <cfargument name="campaign_id" type="string" required="yes">
        <cfargument name="confirmation_email" type="string" required="yes">
        <cfargument name="send_date" type="string" required="no" default="Immediately">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/send.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <Scheduling>
                <ConfirmationEmail>#trim(arguments.confirmation_email)#</ConfirmationEmail>
                <SendDate>#trim(arguments.send_date)#</SendDate>
            </Scheduling>
            </cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)> 
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
	</cffunction>


	<cffunction name="send_campaign_preview" returntype="query" access="public" output="false"
    			hint="Send a preview of any draft campaign to a number of email addresses you specify. You can also set how we should treat any personalization tags in your draft campaign.">
        <cfargument name="campaign_id" type="string" required="yes">
        <cfargument name="preview_recipients" type="array" required="yes">
        <cfargument name="personalize" type="string" required="no" default="Random">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/sendpreview.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var recipient = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
            <PreviewInfo>
                <cfif not ArrayIsEmpty(arguments.preview_recipients)>
                    <PreviewRecipients>
                        <cfloop array="#arguments.preview_recipients#" index="recipient">
                        	<Recipient>#trim(recipient)#</Recipient>
                        </cfloop>
                    </PreviewRecipients>
                </cfif>
                <Personalize>#trim(arguments.personalize)#</Personalize>
            </PreviewInfo>
            </cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)> 
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
	</cffunction>


	<cffunction name="campaign_summary" returntype="query" access="public" output="false"
    			hint="Provides a basic summary of the results for any sent campaign such as the number of recipients, opens, clicks, unsubscribes, etc to date. Also includes the URL of the web version of that campaign.">
        <cfargument name="campaign_id" type="string" required="yes">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/summary.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//Summary')>
        
        <cfset result_query = QueryNew("Bounced,Clicks,Recipients,TotalOpened,UniqueOpened,Unsubscribed,WebVersionURL,Likes,Forwards,Mentions,SpamComplaints")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "Bounced", item.Bounced.XMLText)>
            <cfset QuerySetCell(result_query, "Clicks", item.Clicks.XMLText)>
            <cfset QuerySetCell(result_query, "Recipients", item.Recipients.XMLText)>
            <cfset QuerySetCell(result_query, "TotalOpened", item.TotalOpened.XMLText)>
            <cfset QuerySetCell(result_query, "UniqueOpened", item.UniqueOpened.XMLText)>
            <cfset QuerySetCell(result_query, "Unsubscribed", item.Unsubscribed.XMLText)>
            <cfset QuerySetCell(result_query, "WebVersionURL", item.WebVersionURL.XMLText)>
            <cfset QuerySetCell(result_query, "SpamComplaints", item.SpamComplaints.XMLText)>
            <cfset QuerySetCell(result_query, "Likes", item.Likes.XMLText)>
            <cfset QuerySetCell(result_query, "Forwards", item.Forwards.XMLText)>
            <cfset QuerySetCell(result_query, "Mentions", item.Mentions.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="campaign_lists" returntype="query" access="public" output="false"
    			hint="Returns the lists any campaign was sent to.">
        <cfargument name="campaign_id" type="string" required="yes">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/listsandsegments.xml">
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


	<cffunction name="campaign_segments" returntype="query" access="public" output="false"
    			hint="Returns the segments any campaign was sent to.">
        <cfargument name="campaign_id" type="string" required="yes">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/listsandsegments.xml">
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


	<cffunction name="campaign_recipients" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all the subscribers that a given campaign was sent to. This includes their email address and the ID of the list they are a member of. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="campaign_id" type="string" required="yes">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/recipients.xml?page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        <cfset var recipient = "">
        
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("EmailAddress,ListID"))>
            
            <cfloop array="#item.Results.XMLChildren#" index="recipient">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", recipient.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "ListID", recipient.ListID.XMLText)>
            </cfloop>
            
            <cfset QuerySetCell(result_query, "ResultsOrderedBy", item.ResultsOrderedBy.XMLText)>
            <cfset QuerySetCell(result_query, "RecordsOnThisPage", item.RecordsOnThisPage.XMLText)>
            <cfset QuerySetCell(result_query, "TotalNumberOfRecords", item.TotalNumberOfRecords.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="campaign_bounces" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all the subscribers who bounced for a given campaign, and the type of bounce (Hard = Hard Bounce, Soft = Soft Bounce). You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="campaign_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/bounces.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        <cfset var recipient = "">
        
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("EmailAddress,ListID,BounceType,Date,Reason"))>
            
            <cfloop array="#item.Results.XMLChildren#" index="recipient">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", recipient.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "ListID", recipient.ListID.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "BounceType", recipient.BounceType.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", recipient.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Reason", recipient.Reason.XMLText)>
            </cfloop>
            
            <cfset QuerySetCell(result_query, "ResultsOrderedBy", item.ResultsOrderedBy.XMLText)>
            <cfset QuerySetCell(result_query, "RecordsOnThisPage", item.RecordsOnThisPage.XMLText)>
            <cfset QuerySetCell(result_query, "TotalNumberOfRecords", item.TotalNumberOfRecords.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="campaign_opens" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all subscribers who opened the email for a given campaign, including the date/time (in format 'YYYY-MM-DD HH:MM:SS') and IP address they opened the campaign from. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="campaign_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/opens.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        <cfset var recipient = "">
        
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("EmailAddress,ListID,Date,IPAddress"))>
            
            <cfloop array="#item.Results.XMLChildren#" index="recipient">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", recipient.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "ListID", recipient.ListID.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", recipient.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "IPAddress", recipient.IPAddress.XMLText)>
            </cfloop>
            
            <cfset QuerySetCell(result_query, "ResultsOrderedBy", item.ResultsOrderedBy.XMLText)>
            <cfset QuerySetCell(result_query, "RecordsOnThisPage", item.RecordsOnThisPage.XMLText)>
            <cfset QuerySetCell(result_query, "TotalNumberOfRecords", item.TotalNumberOfRecords.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="campaign_clicks" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all subscribers who clicked a link in the email for a given campaign, including the date/time and IP address they clicked the campaign from. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="campaign_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/clicks.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        <cfset var recipient = "">
        
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("EmailAddress,URL,ListID,Date,IPAddress"))>
            
            <cfloop array="#item.Results.XMLChildren#" index="recipient">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", recipient.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "URL", recipient.URL.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "ListID", recipient.ListID.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", recipient.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "IPAddress", recipient.IPAddress.XMLText)>
            </cfloop>
            
            <cfset QuerySetCell(result_query, "ResultsOrderedBy", item.ResultsOrderedBy.XMLText)>
            <cfset QuerySetCell(result_query, "RecordsOnThisPage", item.RecordsOnThisPage.XMLText)>
            <cfset QuerySetCell(result_query, "TotalNumberOfRecords", item.TotalNumberOfRecords.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="campaign_unsubscribes" returntype="query" access="public" output="false"
    			hint="Contains a paged result representing all subscribers who unsubscribed from the email for a given campaign, including the date/time and IP address they unsubscribed from. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="campaign_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/unsubscribes.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        <cfset var recipient = "">
        
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("EmailAddress,ListID,Date,IPAddress"))>
            
            <cfloop array="#item.Results.XMLChildren#" index="recipient">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", recipient.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "ListID", recipient.ListID.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", recipient.Date.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "IPAddress", recipient.IPAddress.XMLText)>
            </cfloop>
            
            <cfset QuerySetCell(result_query, "ResultsOrderedBy", item.ResultsOrderedBy.XMLText)>
            <cfset QuerySetCell(result_query, "RecordsOnThisPage", item.RecordsOnThisPage.XMLText)>
            <cfset QuerySetCell(result_query, "TotalNumberOfRecords", item.TotalNumberOfRecords.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="delete_campaign" returntype="query" access="public" output="false"
    			hint="Deletes a campaign from your account. For draft and scheduled campaigns (prior to the time of scheduling), this will prevent the campaign from sending. If the campaign is already sent or in the process of sending, it will remove the campaign from the account.">
        <cfargument name="campaign_id" type="string" required="yes">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#.xml">
        <cfset var request_method = "delete">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)> 
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
	</cffunction>


	<cffunction name="campaign_email_client_usage" returntype="query" access="public" output="false"
    			hint="Lists the email clients subscribers used to open the campaign. Each entry includes the email client name, the email client version, the percentage of subscribers who used it, and the actual number of subscribers who used it to open the campaign.">
        <cfargument name="campaign_id" type="string" required="yes">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/emailclientusage.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        <cfset xml_result = XMLSearch(xml_result, '//EmailClient')>
        
        <cfset result_query = QueryNew("Client,Version,Percentage,Subscribers")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "Client", item.Client.XMLText)>
            <cfset QuerySetCell(result_query, "Version", item.Version.XMLText)>
            <cfset QuerySetCell(result_query, "Percentage", item.Percentage.XMLText)>
            <cfset QuerySetCell(result_query, "Subscribers", item.Subscribers.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="campaign_spam_complaints" returntype="query" access="public" output="false"
    			hint="Retrieves a paged result representing all subscribers who marked the given campaign as spam, including the subscriber's list ID and the date/time they marked the campaign as spam.">
        <cfargument name="campaign_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('d', -30, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/campaigns/#arguments.campaign_id#/spam.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var item = "">
        <cfset var spam_complaint = "">
        
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
            <cfset QuerySetCell(result_query, "Results", QueryNew("EmailAddress,ListID,Date"))>
            
            <cfloop array="#item.Results.XMLChildren#" index="spam_complaint">
            	<cfset QueryAddRow(result_query["Results"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "EmailAddress", spam_complaint.EmailAddress.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "ListID", spam_complaint.ListID.XMLText)>
                <cfset QuerySetCell(result_query["Results"][result_query.recordcount], "Date", spam_complaint.Date.XMLText)>
            </cfloop>
            
            <cfset QuerySetCell(result_query, "ResultsOrderedBy", item.ResultsOrderedBy.XMLText)>
            <cfset QuerySetCell(result_query, "RecordsOnThisPage", item.RecordsOnThisPage.XMLText)>
            <cfset QuerySetCell(result_query, "TotalNumberOfRecords", item.TotalNumberOfRecords.XMLText)>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>
    
    
</cfcomponent>