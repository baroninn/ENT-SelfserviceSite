function Get-CrayonAPIToken {
    <#
    .SYNOPSIS
        Get an authentication token required for interacting with Crayon REST API. Use the returned header with future GETs


    .EXAMPLE
        Get-CrayonAPIToken

    .NOTES
    Author:      Jakob Strøm
    Contact:     jst@columbusglobal.com
    Created:     2017-10-10
    #>

    Begin {

        $ErrorActionPreference = "Stop"

    }
    
    Process {

            ## Log on to Crayon
            $clientauth = 'd71afcf5-7614-4809-87a6-6198722207f6:2cb129ed-0417-4c5a-b2b7-5b3a37af8197'
            $base64token = [System.Convert]::ToBase64String([char[]]$clientauth);

            $Auth = @{
                'Accept' = 'application/json'
                'Content-Type' = 'application/x-www-form-urlencoded'
                'Authorization' = 'Basic {0}' -f $base64token
            };
            $content = "grant_type=password&username=jst@columbusglobal.com&password=Shareonline.dk!2&scope=CustomerApi";
            $Response = Invoke-RestMethod -Uri "https://api.crayon.com/api/v1/connect/token" -Method POST -Body $content -Headers $Auth
       
            $Header = @{}
            $Header.Add("Authorization", "Bearer "+ $Response.AccessToken)

            return $Header
    }
}
