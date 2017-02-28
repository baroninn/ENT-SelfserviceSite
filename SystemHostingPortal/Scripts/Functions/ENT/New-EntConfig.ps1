function New-EntConfig {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$Organization
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    process{
        $NewConfig = @()
        $NewConfig += [pscustomobject]@{
                UserContainer  = "null"
                ExchangeServer = "null"
                DomainFQDN     = "null"
                Domain         = 'CORP'
                EmailDomains   = [pscustomobject]@{
                    DomainName   = "null"
                    }
                Office365      = [pscustomobject]@{
                    TenantID   = "null"
                    AdminUser  = "null"
                    AdminPass  = "null"
                }
        }
        try{
            Get-Item "C:\ENTConfig\$Organization"
            }catch {
                New-Item "C:\ENTConfig\$Organization" -ItemType Directory
            }
    $NewConfig | ConvertTo-Json | Out-File ("C:\ENTConfig\$Organization\$Organization.txt") -Force

    }
}