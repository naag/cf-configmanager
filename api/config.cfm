<cfsilent>

<cfset rawData = GetHttpRequestData().content />
<cfif IsBinary(rawData)>
    <cfset rawData = ToString(rawData) />
</cfif>

<cfif IsJSON(rawData)>
    <cfset adminSettings = DeserializeJSON(rawData) />
<cfelse>
    <cfheader statuscode="400" statustext="Bad Request" />
    <cfabort />
</cfif>

<cfloop collection="#adminSettings#" item="objName">
    <cftry>
        <!--- for each key in the adminSettings struct, try to initilize the coresponding admin api component --->
        <cfset adminComponent = createObject("component","CFIDE.adminapi.#objName#") />
        <cfset adminObj = adminSettings[objName] />
        <!---
        for each key in the admin api component struct, try to invoke the corresponding setter method
        note: keys correspond to setter methods, without the "set" prefix so
        datasource.mySQL == createObject("component","cfide.adminapi.datasource).setMySQL()
        --->
        <cfloop collection="#adminObj#" item="setter">
            <cftry>

                <cfset invocations = adminObj[setter] />

                <cfloop array="#invocations#" index="args">
                    <cfinvoke component="#adminComponent#" method="set#setter#" argumentCollection="#args#" />
                    <cfset logInfo("Invoked #objName#.set#setter#. Arguments: #serializeJSON(args)#.") />
                </cfloop>

                <cfcatch type="any">
                    <cfset logError("Error invoking #objName#.set#setter#. Error Message: #cfcatch.message#. Arguments: #serializeJSON(args)#.") />
                </cfcatch>

            </cftry>

        </cfloop>

        <cfcatch type="any">
            <cfset logError("Error creating #objName#. #cfcatch.message#") />
        </cfcatch>

    </cftry>

</cfloop>

<cfheader statuscode="200" statustext="Success" />

</cfsilent>