<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Render Webtop Overview --->
<!--- @@description: Renders the Tabs for each status of the object for the Webtop Overview Page  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">

<!------------------ 
START WEBSKIN
 ------------------>
<cfif structKeyExists(stobj,"versionID") AND stobj.versionID NEQ "">
	<!--- IF THIS IS A VERSION OF ANOTHER OBJECT, RUN THIS WEBSKIN WITH THE MAIN VERSION --->
	<cfset html = getView(objectid="#stobj.versionid#", template="renderWebtopOverview", alternateHTML="") />
	<cfif len(html)>
		<cfoutput>#html#</cfoutput>
	<cfelse>
		<cfoutput><h1>OBJECT REVERENCES A VERSION THAT DOES NOT EXIST</h1></cfoutput>
	</cfif>
<cfelse>

	<!--- grab draft object overview --->
	<cfset stDraftObject = StructNew()>
	
	<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
		<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
		<cfif qDraft.recordcount>
			<cfset stDraftObject = getData(qDraft.objectid)>
		</cfif>
	</cfif>



	<extjs:layout id="webtopOverviewViewport" container="Viewport" layout="border">
		<extjs:item region="center" container="TabPanel" activeTab="0">
			
			<cfset oWorkflow = createObject("component", application.stcoapi.farWorkflow.packagepath) />
			
			<cfif StructKeyExists(stobj,"status")>
			
				<cfif len(stobj.status)>
					<cfset mainTabStatus = stobj.status />
				<cfelse>
					<cfset mainTabStatus = "NO STATUS" />
				</cfif>
				
				
				
						

						
				<cfif stobj.status NEQ "" AND NOT structIsEmpty(stDraftObject)>
					<extjs:item title="#stDraftObject.status#" container="Panel" layout="border">

 						<extjs:item region="center" container="Panel" layout="border">			
							<extjs:item region="center" autoScroll="true">
				
								<cfset workflowHTML = oWorkflow.renderWorkflow(referenceID="#stDraftObject.objectid#", referenceTypename="#stDraftObject.typename#") />
								<cfoutput>#workflowHTML#</cfoutput>
								<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewSummary" />
							</extjs:item>
						</extjs:item>	
						<extjs:item region="east" layout="accordion" width="250" cls="webtopOverviewActions">
							<skin:view objectid="#stDraftObject.objectid#" webskin="webtopOverviewActions" />
						</extjs:item>
							

						
					</extjs:item>
				</cfif>	
			<cfelse>
				<cfset mainTabStatus = "Approved/Live" />
			</cfif>
			

	
							
			<extjs:item title="#mainTabStatus#" container="Panel" layout="border">
				<extjs:item region="center" container="Panel" layout="border">			
					<extjs:item region="center" autoScroll="true">
						<cfset workflowHTML = oWorkflow.renderWorkflow(referenceID="#stobj.objectid#", referenceTypename="#stobj.typename#") />
						<cfoutput>#workflowHTML#</cfoutput>
						<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewSummary" />
					</extjs:item>
				</extjs:item>			
				<extjs:item region="east" layout="accordion" width="250" cls="webtopOverviewActions">
					<skin:view objectid="#stobj.objectid#" webskin="webtopOverviewActions" />
				</extjs:item>	
				
				
			</extjs:item>
		</extjs:item>		
	</extjs:layout>

</cfif>


<cfsetting enablecfoutputonly="false">

