<cfcomponent displayname="Unsalted MD5 (extremely weak; DO NOT USE)" hint="I store passwords as unsalted MD5 hashes. I offer no protection against bad guys." extends="PasswordHash"
			alias="md5">

	<cffunction name="matchesHashFormat" hint="Does the string match the format for this hash?" access="public" returntype="boolean">
		<cfargument name="input" type="string" hint="String that may be a password hash" required="true" />
		
		<cfreturn REFind("^[0-9A-Fa-f]{32}$",arguments.input) />
	</cffunction>

	<cffunction name="encode" hint="Convert a clear password to its encoded value" access="public" returntype="string">
		<cfargument name="password" type="string" hint="Input password" required="true" />
		
		<cfreturn Hash(arguments.password,"MD5") />
	</cffunction>

	<cffunction name="passwordMatch" hint="Compare a plain password against an encoded string" access="public" returntype="boolean">
		<cfargument name="password" type="string" hint="Input password" required="true" />
		<cfargument name="hashedPassword" type="string" hint="Previously encoded password string" required="true" />
		<cfargument name="bCheckHashStrength" type="string" default="false" hint="If true, the hash strength of the hashed password must also match those generated by encode()" />
		
		<cfreturn encode(arguments.password) eq arguments.hashedPassword />
	</cffunction>

</cfcomponent>