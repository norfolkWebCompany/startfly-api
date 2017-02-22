<cfcomponent extends="taffy.core.api">
	<cfscript>

		this.mappings['/taffy'] = expandPath('./taffy');
		this.mappings['/resources'] = expandPath('./resources');
		
		this.name = hash(getCurrentTemplatePath());

		variables.framework = {};
		variables.framework.debugKey = "debug";
		variables.framework.reloadKey = "reload";
		variables.framework.reloadPassword = "true";
		variables.framework.serializer = "taffy.core.nativeJsonSerializer";
		variables.framework.returnExceptionsAsJson = true;
		variables.framework.allowCrossDomain = true;
		variables.framework.reloadOnEveryRequest = true;

		function onApplicationStart(){
			return super.onApplicationStart();
		}

		function onRequestStart(TARGETPATH){
			return super.onRequestStart(TARGETPATH);
		}

		// this function is called after the request has been parsed and all request details are known
		function onTaffyRequest(verb, cfc, requestArguments, mimeExt){
			// this would be a good place for you to check API key validity and other non-resource-specific validation
			return true;
		}

	</cfscript>
</cfcomponent>