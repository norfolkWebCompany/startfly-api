<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/avatar/{id}" hint="some hint about this resource">

    <cffunction name="post">
        <cfargument name="file" />
        <cfargument name="id" />

			<cfset objTools = createObject('component','/resources/private/tools') />

			<cfset sTime = getTickCount() />

	        <cfset var local = StructNew() />

	        <cfset fileDir = 'D:\domains\beta.startfly.co.uk\wwwroot\images\partner\'>


	        <cffile
	            action="upload"
	            destination="#fileDir#"
	            fileField="file"
	            nameConflict="MakeUnique"
	            result="local.uploadResult"
	            />

	        <cfset FilePath = FileDir & local.uploadResult.serverFile>

	        <cfimage 
	        	action="read" 
	        	source="#FilePath#" 
	        	name="ThisImg" />


	        <cfif ThisImg.width gt 600>
				<cfset ImageScaleToFit(ThisImg,600,'')>
	        </cfif>
	        <cfif ThisImg.height gt 600>
				<cfset ImageScaleToFit(ThisImg,600,600)>
	        </cfif>


			<cfset objAccum = createObject('component','/resources/private/accum') />
			<cfset newID = objAccum.newID('secureIDPrefix') & '-' & createUUID() />

			<cfset newFileName = newID & '.' & local.uploadResult.ClientFileExt />
			<cfset newFilePath = fileDir & newFileName  />

			<cfimage 
				action="write" 
				destination="#filePath#" 
				source="#ThisImg#" 
				overwrite="yes" 
				quality="1" />

			<cffile 
				action="rename" source="#filePath#" 
				destination="#newFilePath#" 
				attributes="normal" /> 

			<cfquery name="thisPartner" datasource="startfly">
			SELECT avatar 
			FROM partner 
			WHERE sID = '#arguments.id#'
			</cfquery>

			<cfset oldFileName = fileDir & thisPartner.avatar />

			<cfquery datasource="startfly">
			UPDATE partner SET 
			avatar = '#newFileName#'
			WHERE sID = '#arguments.id#'
			</cfquery>

			<cfif fileExists(oldFileName)>
				<cffile 
					action="delete" 
					file="#oldFileName#" />
			</cfif>



			<cfset local.uploadResult.avatar = 'https://beta.startfly.co.uk/images/partner/' & newFileName /> 


			<cfset objTools.runtime('post', '/partner/avatar/{id}', (getTickCount() - sTime) ) />

        <cfreturn representationOf( {args: arguments, result: local.uploadResult} ) />
	</cffunction>


</cfcomponent>
