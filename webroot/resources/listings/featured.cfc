<cfcomponent extends="taffy.core.resource" taffy:uri="/public/listings/featured" hint="some hint about this resource">

	<cffunction name="get" access="public" output="false">

		<cfset result = {} />
		<cfset result['status'] = {} />
		<cfset result['data'] = {} />
		<cfset result['status']['statusCode'] = 200 />
		<cfset result['status']['message'] = 'OK' />

		<cfquery name="featured" datasource="startfly">
		SELECT 
		courseCategory.*
		FROM courseCategory 
		WHERE courseCategory.featured = 1 
		ORDER BY courseCategory.sortOrder, coursecategory.name
		</cfquery>

		<cfset featuredArray = arrayNew(1) />

		<cfloop query="featured">
			<cfset featuredArray[featured.currentRow]['ID'] = featured.ID />
			<cfset featuredArray[featured.currentRow]['name'] = featured.name />
			<cfset featuredArray[featured.currentRow]['boxType'] = featured.boxType />
			<cfset featuredArray[featured.currentRow]['class'] = featured.class />
			<cfset featuredArray[featured.currentRow]['familyID'] = featured.familyID />
			<cfset featuredArray[featured.currentRow]['pageURL'] = featured.URL />
			<cfset featuredArray[featured.currentRow]['imagePath'] = featured.imagePath />
		</cfloop>


		<cfset result['data'] = featuredArray />

		<cfreturn representationOf(result).withStatus(200) />

	</cffunction>


</cfcomponent>
