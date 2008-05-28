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
$Header: /cvs/farcry/core/webtop/admin/config.cfm,v 1.19 2005/09/13 06:34:27 guy Exp $
$Author: guy $
$Date: 2005/09/13 06:34:27 $
$Name: milestone_3-0-1 $
$Revision: 1.19 $

|| DESCRIPTION || 
$DESCRIPTION: config edit handler$
 

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in:$ 
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<cfoutput><h3>#application.rb.getResource("farcryInternalConfigFiles")#</h3></cfoutput>
	<cfparam name="form.action" default="none">
	
	<cfif isDefined("URL.configName")>
		<cfset stTemp = application.config[url.configName]>
		<cfif structKeyExists(stTemp,'editHandler')>
			<cftry>
				<cfinclude template="#stTemp.edithandler#">
				<cfcatch>
					<cfset subS=listToArray('#url.configName#, #stTemp.editHandler#')>
					<cfoutput><h3>#application.rb.formatRBString("customConfigTemplateMissing",subS)#</h3></cfoutput>
				</cfcatch>
			</cftry>
			<cfabort>
		</cfif>
	
	</cfif>
	
	
	<cfswitch expression="#form.action#">
	
		<cfcase value="update">
			<cfif form.stName eq "verity">
				<cfinclude template="config_verity.cfm">
			<cfelse>
			
				<!--- update configs for image and file --->
				<cfset stTemp = structNew()>
				<!--- loop through dynamic form fields and create temp structure with new values --->
				<cfloop list="#form.fieldnames#" index="i">
					<cfif i neq "action" and i neq "stName">
						<cfset stTemp[i] = form[i]>
					</cfif>
				</cfloop>
				<!--- duplicate temp structure to application scope --->
				<cfset "application.config.#form.stName#" = duplicate(stTemp)>
			</cfif>
			
			<!--- set config to database --->
			<cfinvoke component="#application.packagepath#.farcry.config" method="setConfig" returnvariable="setConfigRet">
				<cfinvokeargument name="configName" value="#form.stName#"/>
				<cfinvokeargument name="stConfig" value="#stTemp#"/>
			</cfinvoke>
			
			<cfoutput><p id="fading" class="success fade"><strong>Update complete.</strong></p></cfoutput>
			
		</cfcase>
		
		<cfcase value="none">
			<cfif IsDefined("url.configName")>
				
				<!--- check if verity config, has unique edit handler TODO - update verity config to include this --->
				<cfif url.configName eq "verity">
					<cfinclude template="config_verity.cfm">
				<cfelse>
				
					<cfset stTemp = application.config[url.configName]>
					
									
					<!--- sort structure by Key name --->
					<cfset listofKeys = structKeyList(stTemp)>
					<cfset listofKeys = listsort(listofkeys,"textnocase")>			
					
					<cfoutput>
					<form action="#cgi.script_name#" method="post">
					<input type="Hidden" name="action" value="update">
					<input type="Hidden" name="stName" value="#url.configName#">
					<table class="table-4" cellspacing="0">
					<tr>
					<th scope="col" colspan="2">#application.rb.formatRBString("configName","#url.configName#")#</th>
					</tr>
					<!--- loop through config structure and set up form for editing --->
					<cfloop list="#listOfKeys#" index="field">
						<tr>
							<cfif len(stTemp[field]) LT 60>
								<th scope="row" class="alt">#field#</th>
								<td><input name="#field#" type="text" value="#stTemp[field]#" size="60" /></td>
							<cfelseif int(len(stTemp[field])/60)+1 lt 20>
								<th scope="row" class="alt">#field#</th>
								<td><textarea name="#field#" rows="#int(len(stTemp[field])/60)+1#" cols="57">#stTemp[field]#</textarea></td>
							<cfelse>
								<th scope="row" class="alt">#field#</th>
								<td><textarea name="#field#" rows="20" cols="60">#stTemp[field]#</textarea></td>
							</cfif>
						</tr>
					</cfloop>
					</table>

					<div class="f-submit-wrap">
					<input type="submit" value="#application.rb.getResource("updateConfig")#" class="f-submit" />
					</div>
					
					<hr />
					
					</form>
					</cfoutput>
				</cfif>
			</cfif>
		</cfcase>
		
		<cfdefaultcase><cfdump var="#form#"></cfdefaultcase>
	</cfswitch>
	
	<!--- list config files --->
	<cftry>
		<cfinvoke component="#application.packagepath#.farcry.config" method="list" returnvariable="qConfigs">
		
		<cfif qConfigs.RecordCount eq 0>
			<cfoutput>#application.rb.getResource("noConfigFilesSpecified")#
			<form action="#cgi.script_name#" method="post">
			<input type="Hidden" name="action" value="#application.rb.getResource("defaults")#">
			<input type="submit" value="#application.rb.getResource("installDefaultConfigs")#" class="f-submit" />
			</form></cfoutput>
		<cfelse>
			<cfoutput>
			<ul>
				<cfloop query="qConfigs">
					<li><a href="?configName=#qConfigs.configName#">#qConfigs.configName#</a></li>
				</cfloop>
			</ul>
			</cfoutput>
			
		</cfif>
		
		<cfcatch>
			<cfoutput><form action="#cgi.script_name#" method="post">
			<input type="Hidden" name="action" value="#application.rb.getResource("deploy")#" class="f-submit" />
			<input type="submit" value="#application.rb.getResource("deployConfigTable")#" class="f-submit" />
			</form></cfoutput>
		</cfcatch>
	</cftry>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="no">