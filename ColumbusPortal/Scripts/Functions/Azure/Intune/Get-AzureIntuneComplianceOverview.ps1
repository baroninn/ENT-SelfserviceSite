function Get-AzureIntuneComplianceOverview {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(Mandatory=$true)]
        [string]$ID
    )
    

    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {

        try {
            $Overview = Invoke-RestMethod -Uri "$Endpoint/deviceManagement/deviceCompliancePolicies/$ID/deviceStatusOverview/" -Headers $header -Method Get
        }
        catch {
            throw "No compliance overviews.... $($_.exception)"
        }

        return $Overview
    }
}

