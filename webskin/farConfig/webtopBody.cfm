<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<!------------------------------------------------------------
ACTION
------------------------------------------------------------->
<ft:processform action="Reload configuration">
	<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
	<cfset structclear(application.config) />
	<cfloop list="#oConfig.getConfigKeys()#" index="configkey">
		<cfset application.config[configkey] = oConfig.getConfig(configkey) />
	</cfloop>
	
	<skin:bubble title="Configuration has been reloaded" tags="farConfig,info" />
</ft:processform>

<ft:processform action="Delete / reset">
	<cfif structkeyexists(form,"objectid") and len(form.objectid)>
		<cfset oConfig = createobject("component",application.stCOAPI.farConfig.packagepath) />
		<cfloop list="#form.objectid#" index="thisconfig">
			<cfset stConfig = oConfig.getData(objectid=thisconfig) />
			<cfset oConfig.delete(objectid=thisconfig) />
			
			<cfset thisform = oConfig.getForm(key=stConfig.configkey) />
			<cfif len(thisform)>
				<cfset application.config[stConfig.configkey] = oConfig.getConfig(key=stConfig.configkey) />
				<cfif structkeyexists(application.stCOAPI[thisform],"displayname")>
					<cfset stConfig.configkey = application.stCOAPI[thisform].displayname />
				</cfif>
				<skin:bubble title="Configuration reset" message="#stconfig.configkey# has been reset" tags="farConfig,info" />
			<cfelse>
				<cfset structdelete(application.config,stConfig.configkey) />
				<skin:bubble title="Configuration deleted" message="#stconfig.configkey# has been deleted" tags="farConfig,info" />
			</cfif>
		</cfloop>
	<cfelse>
		<skin:bubble title="Error" message="No configurations selected" tags="farConfig,error" />
	</cfif>
</ft:processform>

<!------------------------------------------------------------
VIEW
------------------------------------------------------------->
<cfset aCustomColumns = arraynew(1) />

<cfset aCustomColumns[1] = structnew() />
<cfset aCustomColumns[1].title = "Key" />
<cfset aCustomColumns[1].sortable = true />
<cfset aCustomColumns[1].property = "configkey" />
<cfset aCustomColumns[1].webskin = "displayCellEditLink" />

<cfset aCustomColumns[2] = structnew() />
<cfset aCustomColumns[2].title = "Description" />
<cfset aCustomColumns[2].webskin = "displayCellHint" />

<cfset aButtons = arraynew(1) />

<cfset aButtons[1] = structnew() />
<cfset aButtons[1].value = "Delete / Reset" />
<cfset aButtons[1].permission = 1 />
<cfset aButtons[1].onclick = "" />

<cfset aButtons[2] = structnew() />
<cfset aButtons[2].value = "Reload configuration" />
<cfset aButtons[2].permission = 1 />
<cfset aButtons[2].onclick = "" />

<ft:objectadmin typename="farConfig" 
				title="Manage Configuration" 
				columnList="datetimelastupdated" 
				sqlorderby="configkey asc" 
				sortableColumns="datetimelastupdated" 
				aCustomColumns="#aCustomColumns#" 
				bSelectCol="true" 
				bShowActionList="false"
				lfilterfields="configkey"
				aButtons="#aButtons#"
				lButtons="Delete / Reset,Reload configuration" />

<cfsetting enablecfoutputonly="true" />