<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{partnerID}/images/{imageID}/delete" hint="some hint about this resource">

	<cffunction name="post" access="public" output="false">
		<cfargument name="partnerID" type="string" required="true" />
		<cfargument name="imageID" type="string" required="true" />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="thisImage" datasource="startfly">
		SELECT *  
		FROM partnerImages 
		WHERE ID = '#arguments.imageID#' 
		AND partnerID = '#arguments.partnerID#'
		</cfquery>


		<cfquery datasource="startfly">
		DELETE FROM partnerImages 
		WHERE ID = '#arguments.imageID#' 
		AND partnerID = '#arguments.partnerID#'
		</cfquery>


        <cfset fileDir = 'D:\domains\beta.startfly.co.uk\wwwroot\images\partner\'>

        <cfset fileName = fileDir & arguments.imageID & '.' & thisImage.fileExtension />

		<cfif fileExists(fileName)>
			<cffile 
				action="delete" 
				file="#fileName#" />
		</cfif>


		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>

</cfcomponent>
