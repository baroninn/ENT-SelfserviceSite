function Set-SQLEntConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [string]$Name,
        [string]$UserContainer,
        [string]$ExchangeServer,
        [string]$DomainFQDN,
        [string]$NETBIOS,
        [string]$CustomerOUDN,
        [string]$AdminUserOUDN,
        [string]$ExternalUserOUDN,
        [string[]]$EmailDomains,
        [string]$TenantID,
        [string]$AdminUser,
        [string]$AdminPass,
        [string]$AADsynced,
        [string]$ADConnectServer,
        [string]$DomainDC,
        [string]$NavMiddleTier,
        [string]$SQLServer,
        [string]$AdminRDS,
        [string]$AdminRDSPort
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $Config = Get-SQLENTConfig -Organization $Organization
    }
    Process {
        
        if(-not $Name -eq '')            {$Config.Name              = "$Name"}
        if(-not $UserContainer -eq '')   {$Config.UserContainer     = "$UserContainer"}
        if(-not $ExchangeServer -eq '')  {$Config.ExchangeServer    = "$ExchangeServer"}
        if(-not $DomainFQDN -eq '')      {$Config.DomainFQDN        = "$DomainFQDN"}
        if(-not $NETBIOS -eq '')         {$Config.NETBIOS           = "$NETBIOS"}
        if(-not $CustomerOUDN -eq '')    {$Config.CustomerOUDN      = "$CustomerOUDN"}
        if(-not $AdminUserOUDN -eq '')   {$Config.AdminUserOUDN     = "$AdminUserOUDN"}
        if(-not $ExternalUserOUDN -eq ''){$Config.ExternalUserOUDN  = "$ExternalUserOUDN"}
        if(-not $EmailDomains -eq '')    {$Config.EmailDomains      =  $EmailDomains -join ',' }
        if(-not $TenantID -eq '')        {$Config.TenantID          = "$TenantID"}
        if(-not $AdminUser -eq '')       {$Config.AdminUser         = "$AdminUser"}
        if(-not $AdminPass -eq '')       {$Config.AdminPass         = "$AdminPass"}
        if(-not $AADsynced -eq '')       {$Config.AADsynced         = "$AADsynced"}
        if(-not $ADConnectServer -eq '') {$Config.ADConnectServer   = "$ADConnectServer"}
        if(-not $DomainDC -eq '')        {$Config.DomainDC          = "$DomainDC"}
        if(-not $NavMiddleTier -eq '')   {$Config.NavMiddleTier     = "$NavMiddleTier"}
        if(-not $SQLServer -eq '')       {$Config.SQLServer         = "$SQLServer"}
        if(-not $AdminRDS -eq '')        {$Config.AdminRDS          = "$AdminRDS"}
        if(-not $AdminRDSPort -eq '')    {$Config.AdminRDSPort      = "$AdminRDSPort"}

        Upload-SQLEntConfig -Organization $Organization -Config $Config

    }

}