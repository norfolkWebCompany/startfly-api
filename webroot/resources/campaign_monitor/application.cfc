<cfcomponent>
    
    <cfset this.name = "CampaignMonitorAPIv3">
    
    <cffunction name="onRequestStart" returnType="boolean" output="false">
        <cfargument name="thePage" type="string" required="true">   
                 
        <cfreturn true>
    </cffunction>   
        

    <cffunction name="onError" returnType="void" output="false">
        <cfargument name="exception" required="true">
        <cfargument name="eventname" type="string" required="true">
        
        <cfset var html_output = "">
        <cfset var uuid = Left(CreateUUID(), 8)>
        
        <div class="error">
            <h3>Error</h3>
            <p>
                <cfoutput>#arguments.exception.message#</cfoutput>
            </p>
        </div>
    	<cfabort>
        
    </cffunction>
    
</cfcomponent>