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
<!--- @@displayname: html div --->
<!--- @@description: A standard HTML div tag usefull when coding so that opening and closing cfoutput tags are not required thereby cleaning up output.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.objectid" /><!--- The objectid of the object being traced --->
	<cfparam name="attributes.typename" /><!--- The typename of the object being traced --->
	<cfparam name="attributes.template" default="" /><!--- The webskin name --->
	<cfparam name="attributes.bAllowTrace" default="true" /><!--- Is the outputting of the wrapping trace div allowed? --->
	
	
    <cftry>
	<cfif structKeyExists(request,"mode") AND request.mode.traceWebskins EQ true AND not request.mode.ajax>				
		<cfset stTrace = structNew() />
		<cfset stTrace.traceID = application.fapi.getUUID() />
		<cfset stTrace.objectid = attributes.objectid />
		<cfset stTrace.typename = attributes.typename />
		<cfset stTrace.template = attributes.template />
		<cfset stTrace.path = replaceNoCase(application.coapi.coapiadmin.getWebskinPath(typename=attributes.typename, template=attributes.template), "\", "/") />
		<cfset stTrace.cacheTimeout = application.coapi.coapiadmin.getWebskinCacheTimeOut(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.browserCacheTimeout = application.coapi.coapiadmin.getBrowserCacheTimeOut(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.proxyCacheTimeout = application.coapi.coapiadmin.getProxyCacheTimeOut(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.cacheStatus = application.coapi.coapiadmin.getWebskinCacheStatus(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.cacheByVars = application.coapi.coapiadmin.getWebskinCacheByVars(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.cacheByRoles = application.coapi.coapiadmin.getWebskinCacheByRoles(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.cacheFlushOnFormPost = application.coapi.coapiadmin.getWebskinCacheFlushOnFormPost(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.cacheTypeWatch = application.coapi.coapiadmin.getWebskinCacheTypeWatch(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.cacheFlushOnObjectChange = application.coapi.coapiadmin.getWebskinCacheFlushOnObjectChange(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.level = arrayLen(request.aAncestorWebskins) />
		<cfset stTrace.bAllowTrace = attributes.bAllowTrace />
		<cfset stTrace.startTickCount = GetTickCount() />
		<cfset arrayAppend(request.aAncestorWebskinsTrace, stTrace) />	
		<cfset arrayPos = arrayLen(request.aAncestorWebskinsTrace) />
		<cfif attributes.bAllowTrace>
			<cfoutput>
			<div id="#stTrace.traceID#" class="webskin-tracer" style="display:none;">
				<div class="webskin-tracer-close" style="text-align:right;" onclick="$j('###stTrace.traceID#').css('display', 'none');$j('###stTrace.traceID#-webskin-border').css('display', 'none');"><a name="#stTrace.traceID#"><img src="#application.url.webtop#/thirdparty/gritter/images/gritter-close.png" /></a></div>			
				<div class="webskin-tracer-bubble">
					<div class="webskin-tracer-bubble-inner">
						
						<table class="webskin-tracer-table">
						<tr>
							<th>ID</th>
							<td>#stTrace.objectid#</td>
						</tr>
						<tr>
							<th>Type</th>
							<td>#stTrace.typename#</td>
						</tr>
						<tr>
							<th>Webskin</th>
							<td>#stTrace.template#</td>
						</tr>
						<tr>
							<th>Path</th>
							<td>
								<cfset lvl = 0 />
								<cfloop list="#stTrace.path#" index="i" delimiters="/">
									<cfif i NEQ "farcry">
										<cfset lvl = lvl + 1 />
										<div style="margin-left:#lvl * 5#px;">/#i#</div>
									</cfif>
								</cfloop>
							</td>
						</tr>
					
						<cfif stTrace.cacheStatus EQ 1>
							<cfif structKeyExists(application.stcoapi, stTrace.typename) AND isDefined("application.stcoapi[stTrace.typename].bObjectBroker") AND application.stcoapi[stTrace.typename].bObjectBroker>										
								<cfset typeCoapiObjectID = application.fapi.getContentType("farCoapi").getCoapiObjectID(stTrace.typename)>
								<cfif typeCoapiObjectID eq stTrace.objectid>
									<cfset cacheColour = "darkorange">
								<cfelse>
									<cfset cacheColour = "green">
								</cfif>

								<tr>
									<th style="color:#cacheColour#;border-top:1px solid #cacheColour#;">Caching</th>
									<td style="border-top:1px solid #cacheColour#;">
										<cfif cacheColour eq "darkorange">
											<div>* Caching is enabled on this webskin but will not work. Only webskins rendered against a real objectid can be cached.</div>
										<cfelseif isNumeric(stTrace.cacheTimeout)>
											<cfset time = stTrace.cacheTimeout>
											<cfset days = time \ 1440 />
											<cfset hours = (time \ 60) - (days * 24) />
											<cfset minutes = (time) - (days * 1440) - (hours * 60) />
											<div>* Caching for <strong>#days# day(s), #hours# hour(s), #minutes# minute(s)</strong>.</div>
										</cfif>
										<cfif stTrace.cacheByRoles>
											<div>* Caching by Roles</div>
										</cfif>
										<cfif stTrace.cacheFlushOnFormPost>
											<div>* Cache will flush on Form Post</div>
										</cfif>
										
										<cfif len(stTrace.cacheTypeWatch)>
											<div>* Cache will flush on any changes to:</div>
											<div style="padding:0px 20px;"><cfloop list="#stTrace.cacheTypeWatch#" index="i"><div>- #i#</div></cfloop></div>
										</cfif>
										
										<cfif isBoolean(stTrace.cacheFlushOnObjectChange) AND stTrace.cacheFlushOnObjectChange>
											<div>* Cache will flush IMMEDIATELY on any changes to this object</div>
										</cfif>
										
										<cfif len(stTrace.cacheByVars)>
											<div>* Caching by the following Variables:</div>
											<div style="padding:0px 20px;"><cfloop list="#stTrace.cacheByVars#" index="i"><div>- #i#</div></cfloop></div>
										</cfif>
										
										<cfif stTrace.proxyCacheTimeout gt -1 or stTrace.browserCacheTimeout gt -1>
											<div>* 
												<cfif stTrace.browserCacheTimeout gt -1>Browser cache timeout: #stTrace.browserCacheTimeout#</cfif>
												<cfif stTrace.proxyCacheTimeout gt -1 or stTrace.browserCacheTimeout gt -1> | </cfif>
												<cfif stTrace.proxyCacheTimeout gt -1>Proxy cache timeout: #stTrace.proxyCacheTimeout#</cfif>
											</div>
										</cfif>
									</td>
								</tr>
								
							<cfelse>
								<tr>
									<td colspan="2" style="color:purple;border-top:1px solid purple;">CACHING ON BUT TYPE NOT CURRENTLY SET TO USE OBJECT BROKER.</td>
								</tr>
							</cfif>
						<cfelseif stTrace.cacheStatus LT 0>
							<tr>
								<td colspan="2" style="color:red;border-top:1px solid red;">THIS WEBSKIN WILL NEVER CACHE OR LET ANCESTORS INCLUDE IT AS PART OF THEIR CACHE.</td>
							</tr>
						</cfif>
						
						
						</table>
						
					</div>
				</div>
			</div>
			<webskin id="#stTrace.traceID#-webskin">
				<div id="#stTrace.traceID#-webskin-border" style="display:none;"></div>
			</cfoutput>
		</cfif>
	</cfif>
    <cfcatch></cfcatch>
</cftry>
</cfif>

<cfif thistag.executionMode eq "End">
	<cfif structKeyExists(request,"mode") AND request.mode.traceWebskins EQ true AND not request.mode.ajax>			
		<cfif attributes.bAllowTrace>
			<cfoutput></webskin></cfoutput>
		</cfif>
		
		<cfset request.aAncestorWebskinsTrace[arrayPos].endTickCount = GetTickCount() />
		<cfset request.aAncestorWebskinsTrace[arrayPos].totalTickCount = (request.aAncestorWebskinsTrace[arrayPos].endTickCount - request.aAncestorWebskinsTrace[arrayPos].startTickCount) / 1000 />
		
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">

