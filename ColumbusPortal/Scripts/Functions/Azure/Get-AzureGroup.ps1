function Get-AzureGroup {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Header,

        [Parameter(Mandatory=$false)]
        [string]$ID
    )
    

    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Endpoint = "https://graph.microsoft.com/beta"
    }
    
    Process {

        if (-not $ID) {

            try {
                $Groups = @(Invoke-RestMethod -Uri "$Endpoint/groups" -Headers $header -Method Get).value
            }
            catch {
                throw "No configurations exist.."
            }

            return $Groups
        }
        else {

            $i = @(Invoke-RestMethod -Uri "$Endpoint/groups/$ID" -Headers $header -Method Get)

            return $i
        }
    }
}
