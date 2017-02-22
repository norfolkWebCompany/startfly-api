<cfset account = CreateObject("component", "cfc.account").init()>
<cfset clients = CreateObject("component", "cfc.clients").init()>
<cfset campaigns = CreateObject("component", "cfc.campaigns").init()>

<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Campaign Monitor API v3 Coldfusion Wrapper Demo</title>
<link rel="stylesheet" type="text/css" href="demo_files/styles.css" />
</head>

<body>
	<cfoutput>
    
        <h1>Campaign Monitor API v3 Coldfusion Wrapper Demo <span>v1.0</span></h1>
        <p class="info">
        	<strong>Updated:</strong> 24th August 2011<br />
        	<strong>Download:</strong> <a href="http://campaignmonitorapi.riaforge.org">campaignmonitorapi.riaforge.org</a><br />
        	<strong>Report issues:</strong> <a href="http://campaignmonitorapi.riaforge.org">campaignmonitorapi.riaforge.org</a><br />
            <strong>CM API Docs:</strong> <a href="http://www.campaignmonitor.com/api">campaignmonitor.com/api</a>
        </p>
        <p class="emphasise">
        	For this demo to work, you need to enter a valid Campaign Monitor API Key at the top of
            cfc/general.cfc. 
        </p>
        <p>
        	Below are some simple examples of a few GET methods from the API. If you have a look through
            the CFCs it should be pretty obvious how to use all of the methods, although I will create a proper
            demo at some point.
        </p>
        <p>
        	Just about all the methods return a query. Sometimes query columns contain further queries. 
            While I realise that some people will want JSON, XML or Structures/Arrays, this is the way
            that suited my app. Some methods just return a true or false value, or a simple string but
            to keep it consistent these are also returned as a query with one column and one row. Pointless?
            Possibly, but that's how I've done it so feel free to edit for your own application.
        </p>
        <p>
        	Errors from the API throw a Coldfusion error which, in the demo, is handled by the onError()
            method in application.cfc. There is an example at the bottom of this page. This suited a simple 
            demo, but if you want to change error handling for your own application, edit handle_error() 
            in cfc/general.cfc and onError() in application.cfc.
        </p>
        <p>
        	There are probably a few scenarios that I haven't fully tested, so be careful when submitting data.
            Obviously I accept no responsibility for anything you break in your CM account, this application
            is provided with no warranty whatsoever.
        </p>
        <p>
        	Please <a href="http://www.louisfiddy.com/contact/">contact me</a> with any comments/suggestions/death threats.
        </p>
        <p>
        	I hope someone finds it useful, please post any problems to the issue tracker at 
            <a href="http://campaignmonitorapi.riaforge.org">campaignmonitorapi.riaforge.org</a>
            so I can fix problems for other users.<br /><br />
            Cheers, <a href="http://www.louisfiddy.com">Louis</a>
        </p>
        
        
        <h2>Clients</h2>
        <p>
        	List of clients associated with the API Key. Grabs the first Client ID to use for 
            the 'Sent Campaigns' example below.
        </p>
        <cfset clients_list = account.clients()>
        <table>
            <tr>
                <th>Client ID</th>
                <th>Name</th>
            </tr>
            <cfloop query="clients_list">
            	<cfif clients_list.currentrow eq 1>
                	<cfset client_id = clients_list.ClientID>
                </cfif>
                <tr>
                    <td>#clients_list.ClientID#</td>
                    <td>#clients_list.Name#</td>
                </tr>
            </cfloop>
        </table>
        
        <h2>Sent Campaigns</h2>
        <p>
            List of sent campaigns. Grabs the first Campaign ID to use for the 'Campaign Summary' example below.
        </p>
        <cfset campaigns_list = clients.sent_campaigns(client_id)>
        <table>
            <tr>
                <th>Campaign ID</th>
                <th>Name</th>
                <th>Subject</th>
                <th>Sent Date</th>
                <th>Total Recipients</th>
                <th>Web Version URL</th>
            </tr>
            <cfloop query="campaigns_list">
            	<cfif campaigns_list.currentrow eq 1>
                	<cfset campaign_id = campaigns_list.CampaignID>
                </cfif>
                <tr>
                    <td>#campaigns_list.CampaignID#</td>
                    <td>#campaigns_list.Name#</td>
                    <td>#campaigns_list.Subject#</td>
                    <td>#DateFormat(campaigns_list.SentDate, 'dd mmmm yyyy')# @ #TimeFormat(campaigns_list.SentDate, 'HH:mm')#</td>
                    <td>#campaigns_list.TotalRecipients#</td>
                    <td><a href="#campaigns_list.WebVersionURL#" target="_blank">#campaigns_list.WebVersionURL#</a></td>
                </tr>
            </cfloop>
        </table>
        
        <h2>Campaign Summary</h2>
        <p>Summary of the campaign.</p>
        <cfset summary = campaigns.campaign_summary(campaign_id)>
        <table>
            <tr>
                <th>Recipients</th>
                <th>Total Opened</th>
                <th>Unique Opened</th>
                <th>Clicks</th>
                <th>Bounced</th>
                <th>Unsubscribed</th>
                <th>Web Version URL</th>
            </tr>
            <cfloop query="summary">
                <tr>
                    <td>#summary.Recipients#</td>
                    <td>#summary.TotalOpened#</td>
                    <td>#summary.UniqueOpened#</td>
                    <td>#summary.Clicks#</td>
                    <td>#summary.Bounced#</td>
                    <td>#summary.Unsubscribed#</td>
                    <td><a href="#summary.WebVersionURL#" target="_blank">#summary.WebVersionURL#</a></td>
                </tr>
            </cfloop>
        </table>
        
        <h2>Campaign Lists</h2>
        <p>Lists used in the campaign.</p>
        <cfset lists = campaigns.campaign_lists(campaign_id)>
        <table>
            <tr>
                <th>List ID</th>
                <th>Name</th>
            </tr>
            <cfloop query="lists">
                <tr>
                    <td>#lists.ListID#</td>
                    <td>#lists.Name#</td>
                </tr>
            </cfloop>
        </table>
        
        <h2>Error Example</h2>
        <p>Deliberately passed an invalid argument to a method to demonstrate an error thrown by the API.</p>
        <cfset lists = campaigns.campaign_lists('not_a_real_id')>
        
    </cfoutput>
</body>
</html>