function Get-EntConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [switch]$JSON # not used for SSS conf pull
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

    }
    Process {

        try{
            $JSONConfig = Get-Content "C:\ENTConfig\$Organization\$Organization.txt" -Raw | ConvertFrom-Json
        }
        catch{
            throw "Unable to get tenant configuration for $Organization. Error: $_"
        }

        if (-not $JSON) {

            $Config = @()
            $Config += [pscustomobject]@{
                    ExchangeServer  = $JSONConfig.ExchangeServer
                    DomainFQDN      = $JSONConfig.DomainFQDN
                    NETBIOS         = $JSONConfig.NETBIOS
                    CustomerOUDN    = $JSONConfig.CustomerOUDN
                    TenantID365     = $JSONConfig.Office365.TenantID
                    AdminUser365    = $JSONConfig.Office365.AdminUser
                    AdminPass365    = $JSONConfig.Office365.AdminPass
                    AADsynced       = $JSONConfig.AADsynced
                    ADConnectServer = $JSONConfig.ADConnectServer
                    DomainDC        = $JSONConfig.DomainDC
            }

            return $Config
        }

        else {

            return $JSONConfig

        }
    }
}