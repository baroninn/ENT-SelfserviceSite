function Set-EntConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [string]$ExchangeServer,
        [string]$DomainFQDN,
        [string[]]$AcceptedDomains,
        [string]$TenantID365,
        [string]$AdminUser365,
        [string]$AdminPass365
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        try{
        $Config = Get-Content ("C:\ENTConfig\$Organization\$Organization.txt") -Raw | ConvertFrom-Json
        }
        catch{ New-ENTConfig -Organization $Organization}

        $Config = Get-Content ("C:\ENTConfig\$Organization\$Organization.txt") -Raw | ConvertFrom-Json
    }
    Process {

        if(-not $ExchangeServer -eq '')  {$Config.ExchangeServer              = "$ExchangeServer"}
        if(-not $DomainFQDN -eq '')      {$Config.DomainFQDN                  = "$DomainFQDN"}
        if(-not $AcceptedDomains -eq '') {$Config.EmailDomains.DomainName     = $AcceptedDomains.replace(' ', '').split(',')}

        if(-not $TenantID365 -eq '')     {$Config.Office365.TenantID          = "$TenantID365"}
        if(-not $AdminUser365 -eq '')    {$Config.Office365.AdminUser         = "$AdminUser365"}
        if(-not $AdminPass365 -eq '')    {$Config.Office365.AdminPass         = "$AdminPass365"}
        $Config | ConvertTo-Json | Out-File ("C:\ENTConfig\$Organization\$Organization.txt") -Force

        return $Config


    }

}