<cfcomponent extends="taffy.core.resource" taffy:uri="/membership/create/image" hint="some hint about this resource">

    <cffunction name="post">
        <cfargument name="file" />
        <cfargument name="id" />


        <cfset var local = StructNew() />

        <cfset fileDir = 'D:\domains\beta.startfly.co.uk\wwwroot\images\membership\tmp\'>


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
        <cfif ThisImg.height gt 300>
			<cfset ImageScaleToFit(ThisImg,'',300)>
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


		<cfset local.uploadResult.imageURL = 'https://beta.startfly.co.uk/images/membership/tmp/' & newFileName /> 

        <cfreturn representationOf( {args: arguments, result: local.uploadResult} ) />
	</cffunction>


</cfcomponent>
