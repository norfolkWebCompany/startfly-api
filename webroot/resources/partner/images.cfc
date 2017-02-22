<cfcomponent extends="taffy.core.resource" taffy:uri="/partner/{id}/images" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">
		<cfargument name="id" type="string" required="true" />


		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />


		<cfquery name="q" datasource="startfly">
			SELECT 
			partnerImages.* 
			FROM partnerImages 
			WHERE partnerID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#" />
		</cfquery>


		<cfset imageArray = arrayNew(1) />
		<cfloop query="q">
			<cfset imageArray[q.currentRow]['ID'] = q.ID />
			<cfset imageArray[q.currentRow]['shown'] = q.shown />
			<cfset imageArray[q.currentRow]['created'] = dateFormat(q.created, "ddd mmm dd yyyy") & ' ' & timeFormat(q.created,"HH:mm:ss") & ' GMT+0100 (BST)' />
			<cfset imageArray[q.currentRow]['imageURL'] = 'https://beta.startfly.co.uk/images/partner/' & q.ID & '.' & q.fileExtension />
		</cfloop>

		<cfset result['data'] = imageArray />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>

    <cffunction name="post">
        <cfargument name="file" />
        <cfargument name="id" />


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


        <cfif ThisImg.width gt 900>
			<cfset ImageScaleToFit(ThisImg,900,'')>
        </cfif>
        <cfif ThisImg.height gt 600>
			<cfset ImageScaleToFit(ThisImg,900,600)>
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


		<cfquery datasource="startfly">
		INSERT INTO partnerImages (
		ID,
		fileExtension,
		partnerID,
		created
		) VALUES (
		'#newID#',
		'#local.uploadResult.ClientFileExt#',
		'#arguments.id#',
		NOW()
		)
		</cfquery>

		<cfset local.uploadResult.imageURL = 'https://beta.startfly.co.uk/images/partner/' & newFileName /> 

		<cfset newImage = structNew() />
			<cfset newImage['ID'] = newID />
			<cfset newImage['shown'] = 1 />
			<cfset newImage['created'] = dateFormat(now(), "ddd mmm dd yyyy") & ' ' & timeFormat(now(),"HH:mm:ss") & ' GMT+0100 (BST)' />
			<cfset newImage['imageURL'] = 'https://beta.startfly.co.uk/images/partner/' & newID & '.' & local.uploadResult.ClientFileExt />
		} />


        <cfreturn representationOf( {args: arguments, result: local.uploadResult, image: newImage} ) />
	</cffunction>


</cfcomponent>
