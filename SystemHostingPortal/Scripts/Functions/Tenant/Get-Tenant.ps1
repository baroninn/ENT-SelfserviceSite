function Get-Tenant {
    [Cmdletbinding()]
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1', 'TenantName')]
        [string]$Name,

        [string]$SearchBase = 'OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk',

        [string]$Server = 'hosting.capto.dk'
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    Process {
        $params = @{
            SearchBase  = $SearchBase
            SearchScope = 'OneLevel'
            Server      = $Server
            Filter      = if ($Name) { "Name -eq '$Name'" } else { '*' }
        }

        $ous = @(Get-ADOrganizationalUnit @params)

        if ($ous) {
            foreach ($ou in $ous) {
                [pscustomobject]@{
                    TenantName = $ou.Name
                }
            }
        }
        else {
            if ($Name) {
                Write-Error "Tenant '$Name' was not found"
            }
            else {
                Write-Error "No tenants found"
            }
        }
    }
}