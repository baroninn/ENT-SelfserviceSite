function Get-AzureAPIToken {
    <#
    .SYNOPSIS
        Get an authentication token required for interacting with Azure REST API. Use the returned header with future GETs

    .PARAMETER Organization
        The only parameter required. When parameter recieved, username and password will be gotten from SQL DB.

    .EXAMPLE
        Get-AzureAPIToken -Organization XXX

    .NOTES
    Author:      Jakob Strøm
    Contact:     jst@columbusglobal.com
    Created:     2017-08-20
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [Parameter(Mandatory=$false)]
        [switch]$GraphAPI
    )

    Begin {

        $ErrorActionPreference = "Stop"

        $Config = Get-SQLEntConfig -Organization $Organization
    }
    
    Process {
        if (-not $GraphAPI) { 
            ## Log in to Azure
            $PayLoad = "resource=https://management.core.windows.net/&client_id=1950a258-227b-4e31-a9cf-717495945fc2&grant_type=password&username=$($Config.AdminUser)&scope=openid&password=$($Config.AdminPass)"

            ### Get Access token
            $Response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/Common/oauth2/token" -Method POST -Body $PayLoad -UseBasicParsing
       
            $Headers = @{}
            $Headers.Add("Authorization", "Bearer "+$Response.access_token)

            return $Headers
        }
        else {

            $username = "$($Config.AdminUser)";
            $password = "$($Config.AdminPass)";
            $client_id = "$($Config.AppID)";
            $client_secret = "$($Config.AppSecret)";
            $tenant_id = "$($Config.TenantID)";
            $resource = "https://graph.microsoft.com";

            # grant_type = password

            $authority = "https://login.microsoftonline.com/$($Config.TenantID)";
            $tokenEndpointUri = "$authority/oauth2/token";
            $content = "grant_type=password&username=$($Config.AdminUser)&password=$($Config.AdminPass)&client_id=$($Config.AppID)&client_secret=$($Config.AppSecret)&resource=$resource";

            $response = Invoke-WebRequest -Uri $tokenEndpointUri -Body $content -Method Post -UseBasicParsing
            $responseBody = $response.Content | ConvertFrom-JSON
       
            $Headers = @{}
            $Headers.Add("Authorization", "Bearer "+ $responseBody.access_token)

            return $Headers
        }
    }
}
