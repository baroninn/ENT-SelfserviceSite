function New-ENTConfig {
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
                UserContainer  = $null
                ExchangeServer = $null
                DomainFQDN     = $null
                Domain         = 'CORP'
                EmailDomains   = [pscustomobject]@{
                    DomainName   = $null
                    }
                Office365      = [pscustomobject]@{
                    TenantID   = $null
                    AdminUser  = $null
                    AdminPass  = $null
                }
        }

    $NewConfig | ConvertTo-Json | Out-File ("C:\ENTScriptsTest\Config\$Organization.txt") -Force

    }
}