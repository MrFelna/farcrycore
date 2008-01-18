<cfcomponent displayname="Farcry Task Definition" hint="Workflow definitions are used as template to create workflow instances" extends="types" output="false" description="Acts as a template for the creation of workflow instances">
	<cfproperty ftSeq="1" ftFieldset="" name="title" type="string" default="" hint="Title of workflow definition" ftLabel="Title" ftType="string" />
	<cfproperty ftSeq="2" ftFieldset="" name="description" type="longchar" default="" hint="Description of workflow definition" ftLabel="Description" />
	<cfproperty ftSeq="3" ftFieldset="" name="aTaskDefs" type="array" default="" hint="An array of task definitions. These are the default tasks created for a workflow on start" ftLabel="Task Definitions" ftType="array" ftJoin="farTaskDef" />
	<cfproperty ftSeq="4" ftFieldset="" name="minToComplete" type="numeric" default="" hint="Minutes to complete. Default time for a specific workflow completion; triggers escalation if exceeded" ftLabel="Minutes to Complete" />
	<cfproperty ftSeq="5" ftFieldset="" name="lTypenames" type="string" default="" hint="List of content types that can be assigned this workflow definition" ftLabel="Typenames" ftType="list" ftListData="getWorkflowTypenameList" ftSelectMultiple="true" />
	<cfproperty ftSeq="6" ftFieldset="" name="workflowStart" type="string" default="" hint="Used to alert task owners on workflow start. View on underlying content type" ftLabel="Start Webskin" ftType="list" ftListData="getWorkflowStartWebskins" ftDefault="workflowStart" />
	<cfproperty ftSeq="7" ftFieldset="" name="workflowEnd" type="string" default="" hint="Used to alert task owners on workflow end. View on underlying content type" ftLabel="End Webskin" ftType="list" ftListData="getWorkflowEndWebskins" ftDefault="workflowEnd" />	
	
	
	<cffunction name="getWorkflowTypenameList" output="false" hint="Returns the list of typenames used by the application" returntype="string">
		
		<cfset var typename = "" />
		<cfset var lResult = "" />
		
		<cfloop list="#structKeyList(application.types)#" index="typename">
			<cfif structKeyExists(application.types[typename].stProps, "status")>
				<cfset lResult = listAppend(lResult, typename) />
			</cfif>
		</cfloop>
		
		<cfreturn lResult />
	</cffunction>
	

	<cffunction name="getWorkflowStartWebskins" returntype="string">
		<cfargument name="objectid" type="UUID" required="true" />
		
		<cfset var stWorkflowDef = getData(objectid="#arguments.objectid#") />
		<cfset var result = "" />		
		<cfset var iTypename = "" />	
		<cfset var qWebskins = queryNew("blah") />
		
		<cfloop list="#stWorkflowDef.lTypenames#" index="iTypename">
			<cfset qWebskins = application.coapi.coapiadmin.getWebskins(typename="#iTypename#", prefix="workflowStart", excludeWebskins="#result#") />

			<cfloop query="qWebskins">
				<cfset result = listAppend(result, "#qWebskins.methodname#:#qWebskins.displayName#") />
			</cfloop>
			
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getWorkflowEndWebskins" returntype="string">
		<cfargument name="objectid" type="UUID" required="true" />
		
		<cfset var stWorkflowDef = getData(objectid="#arguments.objectid#") />
		<cfset var result = "" />		
		<cfset var iTypename = "" />	
		<cfset var qWebskins = queryNew("blah") />
		
		<cfloop list="#stWorkflowDef.lTypenames#" index="iTypename">
			<cfset qWebskins = application.coapi.coapiadmin.getWebskins(typename="#iTypename#", prefix="workflowEnd", excludeWebskins="#result#") />

			<cfloop query="qWebskins">
				<cfset result = listAppend(result, "#qWebskins.methodname#:#qWebskins.displayName#") />
			</cfloop>
			
		</cfloop>
		
		<cfreturn result />
	</cffunction>
		
	<cffunction name="onStart" output="false" hint="fires the workflowStart webskin when workflow is created">
	
	</cffunction>
	
	<cffunction name="onTaskChange" output="false" hint="Fires whenever an associated task changes. Checks to see if all tasks are complete; trigger for onEnd()">
	
	</cffunction>
	
	<cffunction name="onEnd" output="false" hint="fires the workflowEnd webskin when workflow is complete">
	
	</cffunction>

</cfcomponent>