<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: Webtop Overview --->
<!--- @@description: The default webskin to use to render the object's summary in the webtop overview screen  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<!------------------ 
START WEBSKIN
 ------------------>

<ft:fieldset legend="#application.fapi.getContentTypeMetadata(stobj.typename,'displayname',stobj.typename)# Information">
	
	<ft:field label="Label" bMultiField="true">
		<cfoutput>#stobj.label#</cfoutput>
	</ft:field>	
	
	
	<cfif application.fapi.getContentTypeMetadata(stobj.typename,'bUseInTree',false)>
		
		<nj:getNavigation objectId="#stobj.objectid#" r_objectID="parentID" bInclusive="1">
		
		<cfif len(parentID)>
		
			<ft:field label="Breadcrumb" bMultiField="true">
			
				<cfif len(parentID)>
					<cfif stobj.typename EQ "dmNavigation">
						<cfset qAncestors = application.factory.oTree.getAncestors(objectid=parentID,bIncludeSelf=false) />
					<cfelse>
						<cfset qAncestors = application.factory.oTree.getAncestors(objectid=parentID,bIncludeSelf=true) />
					</cfif>
					
					<cfif qAncestors.recordCount>
						<cfloop query="qAncestors">
							<skin:buildLink href="#application.url.webtop#/edittabOverview.cfm" urlParameters="objectID=#qAncestors.objectid#" linktext="#qAncestors.objectName#" />
							<cfoutput>&nbsp;&raquo;&nbsp;</cfoutput>
						</cfloop>
						<cfoutput>#stobj.label#</cfoutput>
					<cfelse>
						<cfoutput>#stobj.label#</cfoutput>
					</cfif>
				</cfif>
			
				
				<ft:fieldHint>
					<cfoutput>
					This shows you the selected content item in the context of your site. 
					You can <ft:button value="create a child" renderType="link" url="#application.url.farcry#/conjuror/evocation.cfm?parenttype=dmNavigation&objectId=#parentID#&typename=dmNavigation&ref=#url.ref#" /> navigation item under this.
					</cfoutput>
				</ft:fieldHint>
			</ft:field>
		<cfelse>

			<ft:field label="Breadcrumb" bMultiField="true">
			
				<cfoutput>--- not in tree ---</cfoutput>
			
				<ft:fieldHint>
					<cfoutput>
					This shows you the selected content item in the context of your site. 
					</cfoutput>
				</ft:fieldHint>
			</ft:field>		
		</cfif>
	</cfif>		
	
	
	
	<cfif structKeyExists(stobj, "teaser")>
		<ft:field label="Teaser" bMultiField="true">
			<cfoutput><cfif len(stobj.teaser)>#stobj.teaser#<cfelse>-- none --</cfif></cfoutput>
		</ft:field>
	</cfif>
	<cfif structKeyExists(stobj, "displayMethod")>
		<ft:field label="Webskin">
			<cfoutput>#application.fapi.getWebskinDisplayName(stobj.typename, stobj.displayMethod)# (#stobj.displayMethod#)</cfoutput>
		</ft:field>
	</cfif>
</ft:fieldset>



<cfsetting enablecfoutputonly="false">