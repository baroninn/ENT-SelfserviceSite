function Set-EntConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [string]$ExchangeServer,
        [string]$DomainFQDN,
        [string]$NETBIOS,
        [string]$CustomerOUDN,
        [string[]]$Domains,
        [string]$TenantID365,
        [string]$AdminUser365,
        [string]$AdminPass365,
        [string]$AADsynced,
        [string]$ADConnectServer,
        [string]$DomainDC
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
        if(-not $NETBIOS -eq '')         {$Config.NETBIOS                     = "$NETBIOS"}
        if(-not $CustomerOUDN -eq '')    {$Config.CustomerOUDN                = "$CustomerOUDN"}

        if(-not $Domains -eq '')         {$Config.EmailDomains.DomainName     = $Domains}
        ##    foreach($i in $Domains2) {
        ##        $Config.EmailDomains.DomainName += $i
        ##    }
        ##}

        if(-not $TenantID365 -eq '')     {$Config.Office365.TenantID          = "$TenantID365"}
        if(-not $AdminUser365 -eq '')    {$Config.Office365.AdminUser         = "$AdminUser365"}
        if(-not $AdminPass365 -eq '')    {$Config.Office365.AdminPass         = "$AdminPass365"}

        if(-not $AADsynced -eq '')       {$Config.AADsynced                   = "$AADsynced"}
        if(-not $ADConnectServer -eq '') {$Config.ADConnectServer             = "$ADConnectServer"}
        if(-not $DomainDC -eq '')        {$Config.DomainDC                    = "$DomainDC"}

        $Config | ConvertTo-Json | Out-File ("C:\ENTConfig\$Organization\$Organization.txt") -Force

        return $Config


    }

}