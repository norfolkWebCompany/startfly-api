<cfcomponent extends="taffy.core.resource" taffy:uri="/listing/create/image" hint="some hint about this resource">

    <cffunction name="post">
        <cfargument name="file" />
        <cfargument name="id" />

        <cfset objAccum = createObject('component','/resources/private/accum') />
        <cfset objTools = createObject('component','/resources/private/tools') />
        <cfset internalPartnerID = objTools.internalID('partner',arguments.partnerID) />

        <cfset var local = StructNew() />

        <cfset fileDir = 'D:\domains\beta.startfly.co.uk\wwwroot\images\library\'>


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
            name="tileImage" />

        <cfset desiredWidth = 420 />
        <cfset desiredHeight = 280 />

        <!--- first lets blow it up to the right size --->
        <cfset ImageScaleToFit(tileImage,'',desiredHeight,'mediumQuality') />
        <cfif tileImage.width lt desiredWidth>
            <cfset ImageScaleToFit(tileImage,desiredWidth,'') />
        </cfif>

        <cfset imageCrop(tileImage, (tileImage.width / 2) - (desiredWidth / 2), (tileImage.height / 2) - (desiredHeight / 2), desiredWidth, desiredHeight) />

        <cfset groupID = objAccum.newID('secureIDPrefix') />


        <cfset newID = objAccum.newID('secureIDPrefix') & '-' & createUUID() />

        <cfset tileFileName = newID & '.' & local.uploadResult.ClientFileExt />
        <cfset tileFilePath = fileDir & tileFileName  />

        <cfimage 
            action="write" 
            destination="#tileFilePath#" 
            source="#tileImage#" 
            overwrite="yes" 
            quality="1" />


            <cfquery datasource="startfly" result="qResult">
            INSERT INTO images (
                groupID,
                imagePath,
                type,
                size,
                ownerID,
                ownerType,
                status,
                created            
            ) VALUES (
                #groupID#,
                '#tileFileName#',
                'listing',
                'tile',
                #internalPartnerID#,
                'partner',
                1,
                NOW()
            )
            </cfquery>


        <!--- now the cover image --->
        <cfimage 
        	action="read" 
        	source="#FilePath#" 
        	name="coverImage" />

        <cfset desiredWidth = 1500 />
        <cfset desiredHeight = 750 />

        <!--- first lets blow it up to the right size --->
        <cfset ImageScaleToFit(coverImage,'',desiredHeight,'mediumQuality') />
        <cfif coverImage.width lt desiredWidth>
            <cfset ImageScaleToFit(coverImage,desiredWidth,'') />
        </cfif>

        <cfset imageCrop(coverImage, (coverImage.width/2) - (desiredWidth/2), (coverImage.height/2) - (desiredHeight/2), desiredWidth, desiredHeight)>

        <cfset newID = objAccum.newID('secureIDPrefix') & '-' & createUUID() />
		<cfset coverFileName = newID & '.' & local.uploadResult.ClientFileExt />
		<cfset coverFilePath = fileDir & coverFileName  />

        <cfimage 
            action="write" 
            destination="#coverFilePath#" 
            source="#coverImage#" 
            overwrite="yes" 
            quality="1" />


		<cffile 
			action="delete" file="#filePath#" />

            <cfquery datasource="startfly" result="qResult">
            INSERT INTO images (
                groupID,
                imagePath,
                type,
                size,
                ownerID,
                ownerType,
                status,
                created            
            ) VALUES (
                #groupID#,
                '#coverFileName#',
                'listing',
                'cover',
                #internalPartnerID#,
                'partner',
                1,
                NOW()
            )
            </cfquery>


		<cfset local.uploadResult.ID = qResult.generatedKey />
        <cfset local.uploadResult.imageURL = 'https://beta.startfly.co.uk/images/library/' & tileFileName /> 

        <cfreturn representationOf( {args: arguments, result: local.uploadResult} ) />
	</cffunction>


</cfcomponent>
