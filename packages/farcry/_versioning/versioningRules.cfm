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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_versioning/versioningRules.cfm,v 1.10 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
		
<cfif NOT isDefined("arguments.typename")>
	<cfinvoke component="farcry.core.packages.fourq.fourq" returnvariable="thisTypename" method="findType" objectID="#arguments.ObjectId#">
	<cfset typename = thisTypename> 					
</cfif>

<cfset typename = application.types[typename].typePath>

<q4:contentobjectget ObjectId="#objectId#" r_stObjects="stObject" typename="#typename#"> 

<!--- Determine if draft/pending objects have a live parent --->
<cfscript>
	/*init struct - probably including too much stuff here - but extras may be useful at some point*/
	stRules = structNew();
	stRules.versioning = true;// Is versioning performed on this object?
	stRules.bEdit = false; // Can the user edit this object?
	stRules.bComment = false; //can the user make comments on object
	stRules.bApprove = false; //can user approve object - ie send live
	stRules.bDecline = false; // can user send object back to draft
	stRules.bCreateDraft = false; // create a draft version of object to edit?
	stRules.bDraftVersionExists = false;
	stRules.bLiveVersionExists = false;
	stRules.draftObjectID = "";//this objectID (if exists) of the draft object
	// check if status is part of object
	if (NOT structKeyExists(stObject,"versionID"))
		stRules.status = false; 	
	else
	{	
		stRules.status = stObject.status; //draft,pending,approved?
	}
	stRules.bDeleteDraft = false;
	
	
	// if property doesn't exist - the versioning is not an issue
	if (NOT structKeyExists(stObject,"versionID"))
		stRules.versioning = false; 	
	else
	{	
		if (len(trim(stObject.versionID)) NEQ 0)  // flags whether a live version of this object exists
			stRules.bLiveVersionExists = true;
		else
			stRules.bLiveVersionExists = false;	
		switch (stRules.status){
			case "approved":
				stRules.bComment = true;
				stRules.bDecline = true;  //need to make sure relevant permissions to do this on calling page
				stRules.bCreateDraft = true;
				break;
			case "pending" :
				if (stRules.bLiveVersionExists) {
					stRules.bComment = true;
					stRules.bPreview = true;
					stRules.bApprove = true;
					stRules.bDecline = true;
					break;
				}	
				else
				{
					stRules.bComment = true;
					stRules.bApprove = true;	
					stRules.bDecline = true;
					break;
				}
			case "draft" :
				if (stRules.bLiveVersionExists){
					stRules.bEdit = true;
					stRules.bApprove = true;
					stRules.bComment = true;
					break;
				}
				else
				{
					stRules.bEdit = true;
					stRules.bComment = true;
					stRules.bApprove = true;
					break;
				}
			}
		}		
</cfscript>
<!--- Now check to see if a draft version exists --->
<cfif stRules.status IS "Approved" and structKeyExists(stObject,"versionID")>
	<cfquery datasource="#application.dsn#" name="qHasDraft">
		SELECT objectID,status from #application.dbowner##stObject.typename# where versionID = '#objectID#' 
	</cfquery>
	<cfif qHasDraft.recordcount GT 1>
		<cfthrow extendedinfo="Multiple draft children returned" message="Multiple draft error">
	<cfelseif qHasDraft.recordcount eq 1>
		<cfscript>
			stRules.bDraftVersionExists = true;
			stRules.bDecline = false;
			stRules.draftObjectID = qHasDraft.objectID;
			stRules.draftStatus = qHasDraft.status;
			stRules.bDeleteDraft = true; 
		</cfscript>
	</cfif> 
</cfif>