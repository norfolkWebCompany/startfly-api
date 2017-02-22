<cfcomponent extends="general" output="false">


	<cffunction name="init" access="public" output="false">
		<cfreturn this>
	</cffunction>


	<cffunction name="create_segment" returntype="query" access="public" output="false"
    			hint="Creates a new segment for a specific list. Please keep in mind that: 1) The Rules collection is optional. Individual Rules can also be added incrementally. 2) Rules can be complicated. The full range of segment rules is available through the API, so we have provided more in-depth detail on segment rule construction. The example above creates a segment of any subscribers from 'domain.com' who subscribed at any point during the year 2009.">
        <cfargument name="list_id" type="string" required="yes">
        <cfargument name="title" type="string" required="yes">
        <cfargument name="rules" type="array" required="no" default="#ArrayNew(1)#">
        
        <!---
			
			The 'rules' argument of this method takes an array of segment rules.
			I realise that this could have been a query, xml, json or a number of other data formats,
			but I did it this way so feel free to edit if you disagree :)
			
			Here's a lengthy example of how you could create this:
			
			<cfset rules = ArrayNew(1)>
			
			<cfset ArrayAppend(rules, StructNew())>
			<cfset rules[ArrayLen(rules)].subject = 'EmailAddress'>
			<cfset rules[ArrayLen(rules)].clauses = ArrayNew(1)>
			<cfset rules[ArrayLen(rules)].clauses[1] = 'CONTAINS @domain.com'>
			
			<cfset ArrayAppend(rules, StructNew())>
			<cfset rules[ArrayLen(rules)].subject = 'DateSubscribed'>
			<cfset rules[ArrayLen(rules)].clauses = ArrayNew(1)>
			<cfset rules[ArrayLen(rules)].clauses[1] = 'AFTER 2009-01-01'>
			<cfset rules[ArrayLen(rules)].clauses[2] = 'EQUALS 2009-01-01'>
			
		--->
        
        <cfset var request_url = "/segments/#arguments.list_id#.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var xml_result_success = "">
        <cfset var rule = "">
        <cfset var clause = "">
        <cfset var item = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
                <Segment>
                    <Title>#trim(arguments.title)#</Title>
                    <cfif not ArrayIsEmpty(arguments.rules)>
                        <Rules>
                        	<cfloop array="#arguments.rules#" index="rule">
                                <Rule>
                                    <Subject>#trim(rule.subject)#</Subject>
                                    <Clauses>
                        				<cfloop array="#rule.clauses#" index="clause">
                                        	<Clause>#trim(clause)#</Clause>
                                    	</cfloop>
                                    </Clauses>
                                </Rule>
                            </cfloop>
                        </Rules>
                    </cfif>
                </Segment>
            </cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>   
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)> 
        
        <cfset xml_result_success = XMLSearch(xml_result, '//string')>
        
        <cfif not ArrayIsEmpty(xml_result_success)>       
        
			<cfset result_query = QueryNew("SegmentID")>
            
            <cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "SegmentID", xml_result.string.XMLText)>
        
        <cfelse>
        
			<cfset xml_result = trim(response)>
            <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
            <cfset xml_result = XMLParse(xml_result)>
            
            <cfset xml_result = XMLSearch(xml_result, '//RuleResult')>
            
            <cfset result_query = QueryNew("Code,Message,ClauseResults,Subject")>
            
            <cfloop array="#xml_result#" index="item">
                <cfset QueryAddRow(result_query)>
                <cfset QuerySetCell(result_query, "Code", item.Code.XMLText)>
                <cfset QuerySetCell(result_query, "Message", item.Message.XMLText)>
                <cfset QuerySetCell(result_query, "Subject", item.Subject.XMLText)>
                <cfset QuerySetCell(result_query, "ClauseResults", QueryNew("Code,Message,Clause"))>
            
                <cfloop array="#item.ClauseResults.XMLChildren#" index="clause">
                    <cfset QueryAddRow(result_query["ClauseResults"][result_query.recordcount])>
                    <cfset QuerySetCell(result_query["ClauseResults"][result_query.recordcount], "Code", clause.Code.XMLText)>
                    <cfset QuerySetCell(result_query["ClauseResults"][result_query.recordcount], "Message", clause.Message.XMLText)>
                    <cfset QuerySetCell(result_query["ClauseResults"][result_query.recordcount], "Clause", clause.Clause.XMLText)>
                </cfloop>
            </cfloop>
        
        </cfif>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="update_segment" returntype="query" access="public" output="false"
    			hint="Updates the name of an existing segment and optionally overwrite any existing segment rules with new rules. 1) Updating a segment will always attempt to change the Title, which is compulsory. 2) The Rules collection is optional when updating. If it is present, all existing rules will be deleted before parsing the new ones. If it is not present, existing rules will remain unchanged.">
        <cfargument name="segment_id" type="string" required="yes">
        <cfargument name="title" type="string" required="yes">
        <cfargument name="rules" type="array" required="no" default="#ArrayNew(1)#">
        
        <!---
			
			The 'rules' argument of this method takes an array of segment rules.
			I realise that this could have been a query, xml, json or a number of other data formats,
			but I did it this way so feel free to edit if you disagree :)
			
			Here's a lengthy example of how you could create this:
			
			<cfset rules = ArrayNew(1)>
			
			<cfset ArrayAppend(rules, StructNew())>
			<cfset rules[ArrayLen(rules)].subject = 'EmailAddress'>
			<cfset rules[ArrayLen(rules)].clauses = ArrayNew(1)>
			<cfset rules[ArrayLen(rules)].clauses[1] = 'CONTAINS @domain.com'>
			
			<cfset ArrayAppend(rules, StructNew())>
			<cfset rules[ArrayLen(rules)].subject = 'DateSubscribed'>
			<cfset rules[ArrayLen(rules)].clauses = ArrayNew(1)>
			<cfset rules[ArrayLen(rules)].clauses[1] = 'AFTER 2009-01-01'>
			<cfset rules[ArrayLen(rules)].clauses[2] = 'EQUALS 2009-01-01'>
			
		--->
        
        <cfset var request_url = "/segments/#arguments.segment_id#.xml">
        <cfset var request_method = "put">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var result_query = "">
        <cfset var rule = "">
        <cfset var clause = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
                <Segment>
                    <Title>#trim(arguments.title)#</Title>
                    <cfif not ArrayIsEmpty(arguments.rules)>
                        <Rules>
                        	<cfloop array="#arguments.rules#" index="rule">
                                <Rule>
                                    <Subject>#trim(rule.subject)#</Subject>
                                    <Clauses>
                        				<cfloop array="#rule.clauses#" index="clause">
                                        	<Clause>#trim(clause)#</Clause>
                                    	</cfloop>
                                    </Clauses>
                                </Rule>
                            </cfloop>
                        </Rules>
                    </cfif>
                </Segment>
            </cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>     
        
		<cfset result_query = QueryNew("Success")>
        
        <cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="add_segment_rule" returntype="query" access="public" output="false"
    			hint="Adds a new rule to an existing segment. Adding a Rule will not remove any existing rules on the segment, but simply add an additional requirement for membership.">
        <cfargument name="segment_id" type="string" required="yes">
        <cfargument name="subject" type="string" required="yes">
        <cfargument name="clauses" type="array" required="yes">
        
        <!---
			
			The 'rules' argument of this method takes an array of segment rules.
			I realise that this could have been a query, xml, json or a number of other data formats,
			but I did it this way so feel free to edit if you disagree :)
			
			Here's a lengthy example of how you could create this:
			
			<cfset rules = ArrayNew(1)>
			
			<cfset ArrayAppend(rules, StructNew())>
			<cfset rules[ArrayLen(rules)].subject = 'EmailAddress'>
			<cfset rules[ArrayLen(rules)].clauses = ArrayNew(1)>
			<cfset rules[ArrayLen(rules)].clauses[1] = 'CONTAINS @domain.com'>
			
			<cfset ArrayAppend(rules, StructNew())>
			<cfset rules[ArrayLen(rules)].subject = 'DateSubscribed'>
			<cfset rules[ArrayLen(rules)].clauses = ArrayNew(1)>
			<cfset rules[ArrayLen(rules)].clauses[1] = 'AFTER 2009-01-01'>
			<cfset rules[ArrayLen(rules)].clauses[2] = 'EQUALS 2009-01-01'>
			
		--->
        
        <cfset var request_url = "/segments/#arguments.segment_id#/rules.xml">
        <cfset var request_method = "post">
        <cfset var request_body = "">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var xml_result_data = "">
        <cfset var clause = "">
        <cfset var item = "">
        
        <cfsavecontent variable="request_body">
        	<cfoutput>
                <Rule>
                    <Subject>#trim(arguments.subject)#</Subject>
                    <Clauses>
                        <cfloop array="#arguments.clauses#" index="clause">
                            <Clause>#trim(clause)#</Clause>
                        </cfloop>
                    </Clauses>
                </Rule>
            </cfoutput>
        </cfsavecontent>
        
        <cfset response = http_request(request_url, request_method, request_body)>   
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)> 
        
        <cfset xml_result_data = XMLSearch(xml_result, '//ClauseResult')>
        
        <cfif not ArrayIsEmpty(xml_result_data)> 
        
			<cfset xml_result = trim(response)>
            <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
            <cfset xml_result = XMLParse(xml_result)>
            
            <cfset xml_result = XMLSearch(xml_result, '//RuleResult')>
            
            <cfset result_query = QueryNew("Code,Message,Clause")>
            
            <cfloop array="#xml_result#" index="item">
                <cfset QueryAddRow(result_query)>
                <cfset QuerySetCell(result_query, "Code", item.Code.XMLText)>
                <cfset QuerySetCell(result_query, "Message", item.Message.XMLText)>
                <cfset QuerySetCell(result_query, "Clause", item.Clause.XMLText)>
            </cfloop>      
        
        <cfelse>
        
			<cfset result_query = QueryNew("Success")>
            
            <cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "Success", "true")>
        
        </cfif>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="segment_details" returntype="query" access="public" output="false"
    			hint="Returns the name, list ID, segment ID and number of active subscribers within an existing segment as well as the current rules for that segment.">
        <cfargument name="segment_id" type="string" required="yes">
        
        <cfset var request_url = "/segments/#arguments.segment_id#.xml">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var rule = "">
        <cfset var clause = "">
        <cfset var item = "">
        
        <cfset response = http_request(request_url, request_method)>
        
        <cfset xml_result = trim(response)>
        <cfset xml_result = REReplace(xml_result, "^[^<]*", "", "all")>
        <cfset xml_result = XMLParse(xml_result)>
        
        <cfset xml_result = XMLSearch(xml_result, '//Segment')>
        
        <cfset result_query = QueryNew("ListID,SegmentID,Title,ActiveSubscribers,Rules")>
        
        <cfloop array="#xml_result#" index="item">
        	<cfset QueryAddRow(result_query)>
            <cfset QuerySetCell(result_query, "ListID", item.ListID.XMLText)>
            <cfset QuerySetCell(result_query, "SegmentID", item.SegmentID.XMLText)>
            <cfset QuerySetCell(result_query, "Title", item.Title.XMLText)>
            <cfset QuerySetCell(result_query, "ActiveSubscribers", item.ActiveSubscribers.XMLText)>
            <cfset QuerySetCell(result_query, "Rules", QueryNew("Subject,Clauses"))>
            <cfloop array="#item.Rules.XMLChildren#" index="rule">
            	<cfset QueryAddRow(result_query["Rules"][result_query.recordcount])>
                <cfset QuerySetCell(result_query["Rules"][result_query.recordcount], "Subject", rule.Subject.XMLText)>
                <cfset QuerySetCell(result_query["Rules"][result_query.recordcount], "Clauses", QueryNew("Clause"))>
                <cfif not ArrayIsEmpty(rule.Clauses.XMLChildren)>
                    <cfloop array="#rule.Clauses.XMLChildren#" index="clause">
            			<cfset QueryAddRow(result_query["Rules"][result_query.recordcount]["Clauses"][result_query["Rules"][result_query.recordcount].recordcount])>
						<cfset QuerySetCell(result_query["Rules"][result_query.recordcount]["Clauses"][result_query["Rules"][result_query.recordcount].recordcount], "Clause", clause.XMLText)>
                    </cfloop>
                </cfif>
            </cfloop>
        </cfloop>
        
        <cfreturn result_query>
        
	</cffunction>


	<cffunction name="segment_subscribers" returntype="query" access="public" output="false"
    			hint="Returns all of the active subscribers that match the rules for a specific segment. This includes their name, email address, any custom fields and the date they subscribed. You have complete control over how results should be returned including page sizes, sort order and sort direction.">
        <cfargument name="segment_id" type="string" required="yes">
        <cfargument name="date" type="string" required="no" default="#DateFormat(DateAdd('m', -5, Now()), 'yyyy-mm-dd')# 00:00:01">
        <cfargument name="page" type="numeric" required="no" default="1">
        <cfargument name="page_size" type="numeric" required="no" default="100">
        <cfargument name="order_field" type="string" required="no" default="email">
        <cfargument name="order_direction" type="string" required="no" default="asc">
        
        <cfset var request_url = "/segments/#arguments.segment_id#/active.xml?date=#URLEncodedFormat(trim(arguments.date))#&page=#URLEncodedFormat(trim(arguments.page))#&pagesize=#URLEncodedFormat(trim(arguments.page_size))#&orderfield=#URLEncodedFormat(trim(arguments.order_field))#&orderdirection=#URLEncodedFormat(trim(arguments.order_direction))#">
        <cfset var request_method = "get">
        <cfset var response = "">
        <cfset var xml_result = "">
        <cfset var result_query = "">
        <cfset var custom_field = "">
        <cfset var subscriber = "">
        <cfset var item = "">
        
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


	<cffunction name="delete_segment" returntype="query" access="public" output="false"
    			hint="Deletes an existing segment from a subscriber list.">
        <cfargument name="segment_id" type="string" required="yes">
        
        <cfset var request_url = "/segments/#arguments.segment_id#.xml">
        <cfset var request_method = "delete">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)> 
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
	</cffunction>


	<cffunction name="delete_segment_rules" returntype="query" access="public" output="false"
    			hint="Clears out any existing rules for a current segment, basically creating a blank slate where new rules can be added.">
        <cfargument name="segment_id" type="string" required="yes">
        
        <cfset var request_url = "/segments/#arguments.segment_id#/rules.xml">
        <cfset var request_method = "delete">
        <cfset var response = "">
        <cfset var result_query = "">
        
        <cfset response = http_request(request_url, request_method)> 
        
        <cfset result_query = QueryNew("Success")>
        
		<cfset QueryAddRow(result_query)>
        <cfset QuerySetCell(result_query, "Success", "true")>
        
	</cffunction>
    
    
</cfcomponent>