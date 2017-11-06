function Set-SQLEntConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [string]$Platform,
        $Name = [nullstring]::Value,
        $UserContainer = [nullstring]::Value,
        $ExchangeServer = [nullstring]::Value,
        $DomainFQDN = [nullstring]::Value,
        $NETBIOS = [nullstring]::Value,
        $CustomerOUDN = [nullstring]::Value,
        $AdminUserOUDN = [nullstring]::Value,
        $ExternalUserOUDN = [nullstring]::Value,
        $EmailDomains = [nullstring]::Value,
        $TenantID = [nullstring]::Value,
        $AdminUser = [nullstring]::Value,
        $AdminPass = [nullstring]::Value,
        $AADsynced = [nullstring]::Value,
        $ADConnectServer = [nullstring]::Value,
        $DomainDC = [nullstring]::Value,
        $NavMiddleTier = [nullstring]::Value,
        $SQLServer = [nullstring]::Value,
        $AdminRDS = [nullstring]::Value,
        $AdminRDSPort = [nullstring]::Value,
        $AppID = [nullstring]::Value,
        $AppSecret = [nullstring]::Value,
        [string]$ServiceCompute = $null,
        [string]$Service365 = $null,
        [string]$ServiceIntune = $null
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $Config = Get-SQLENTConfig -Organization $Organization
    }
    Process {
       
        if(-not $Platform) {
            $Config.Platform = $Config.Platform
        }
        else {
            $Config.Platform = $Platform
        }

        if($Name -eq [nullstring]::Value) {Write-Verbose "Parameter Name doesn't seem to be set.."}
        elseif ([String]::Empty -eq $Name) {$Config.Name = $null}        
        else{$Config.Name = $Name}

        if($UserContainer -eq [nullstring]::Value) {Write-Verbose "Parameter UserContainer doesn't seem to be set.."}
        elseif ([String]::Empty -eq $UserContainer) {$Config.UserContainer = $null}
        else{$Config.UserContainer = $UserContainer}

        if($ExchangeServer -eq [nullstring]::Value) {Write-Verbose "Parameter ExchangeServer doesn't seem to be set.."}
        elseif([String]::Empty -eq $ExchangeServer) {$Config.ExchangeServer = $null}
        else{$Config.ExchangeServer = $ExchangeServer}

        if($DomainFQDN -eq [nullstring]::Value) {Write-Verbose "Parameter DomainFQDN doesn't seem to be set.."}
        elseif([String]::Empty -eq $DomainFQDN) {$Config.DomainFQDN = $null}
        else{$Config.DomainFQDN = $DomainFQDN}

        if($NETBIOS -eq [nullstring]::Value) {Write-Verbose "Parameter NETBIOS doesn't seem to be set.."}
        elseif([String]::Empty -eq $NETBIOS) {$Config.NETBIOS = $null}
        else{$Config.NETBIOS = $NETBIOS}

        if($CustomerOUDN -eq [nullstring]::Value) {Write-Verbose "Parameter CustomerOUDN doesn't seem to be set.."}
        elseif([String]::Empty -eq $CustomerOUDN) {$Config.CustomerOUDN = $null}
        else{$Config.CustomerOUDN = $CustomerOUDN}

        if($AdminUserOUDN -eq [nullstring]::Value) {Write-Verbose "Parameter AdminUserOUDN doesn't seem to be set.."}
        elseif([String]::Empty -eq $AdminUserOUDN) {$Config.AdminUserOUDN = $null}
        else{$Config.AdminUserOUDN = $AdminUserOUDN}

        if($ExternalUserOUDN -eq [nullstring]::Value) {Write-Verbose "Parameter ExternalUserOUDN doesn't seem to be set.."}
        elseif([String]::Empty -eq $ExternalUserOUDN) {$Config.ExternalUserOUDN = $null}
        else{$Config.ExternalUserOUDN = $ExternalUserOUDN}

        if($EmailDomains -eq [nullstring]::Value) {Write-Verbose "Parameter EmailDomains doesn't seem to be set.."}
        elseif([String]::Empty -eq $EmailDomains) {$Config.EmailDomains = $null}
        else{$Config.EmailDomains = $EmailDomains -join ','}

        if($TenantID -eq [nullstring]::Value) {Write-Verbose "Parameter TenantID doesn't seem to be set.."}
        elseif([String]::Empty -eq $TenantID) {$Config.TenantID = $null}
        else{$Config.TenantID = $TenantID}

        if($AdminUser -eq [nullstring]::Value) {Write-Verbose "Parameter AdminUser doesn't seem to be set.."}
        elseif([String]::Empty -eq $AdminUser) {$Config.AdminUser = $null}
        else{$Config.AdminUser = $AdminUser}

        if($AdminPass -eq [nullstring]::Value) {Write-Verbose "Parameter AdminPass doesn't seem to be set.."}
        elseif([String]::Empty -eq $AdminPass) {$Config.AdminPass = $null}
        else{$Config.AdminPass = $AdminPass}

        if($AADsynced -eq [nullstring]::Value) {Write-Verbose "Parameter AADsynced doesn't seem to be set.."}
        elseif([String]::Empty -eq $AADsynced) {$Config.AADsynced = $null}
        else{$Config.AADsynced = $AADsynced}

        if($ADConnectServer -eq [nullstring]::Value) {Write-Verbose "Parameter ADConnectServer doesn't seem to be set.."}
        elseif([String]::Empty -eq $ADConnectServer) {$Config.ADConnectServer = $null}
        else{$Config.ADConnectServer = $ADConnectServer}

        if($DomainDC -eq [nullstring]::Value) {Write-Verbose "Parameter DomainDC doesn't seem to be set.."}
        elseif([String]::Empty -eq $DomainDC) {$Config.DomainDC = $null}
        else{$Config.DomainDC = $DomainDC}

        if($NavMiddleTier -eq [nullstring]::Value) {Write-Verbose "Parameter NavMiddleTier doesn't seem to be set.."}
        elseif([String]::Empty -eq $NavMiddleTier) {$Config.NavMiddleTier = $null}
        else{$Config.NavMiddleTier = $NavMiddleTier}

        if($SQLServer -eq [nullstring]::Value) {Write-Verbose "Parameter SQLServer doesn't seem to be set.."}
        elseif([String]::Empty -eq $SQLServer) {$Config.SQLServer = $null}
        else{$Config.SQLServer = $SQLServer}

        if($AdminRDS -eq [nullstring]::Value) {Write-Verbose "Parameter AdminRDS doesn't seem to be set.."}
        elseif([String]::Empty -eq $AdminRDS) {$Config.AdminRDS = $null}
        else{$Config.AdminRDS = $AdminRDS}

        if($AdminRDSPort -eq [nullstring]::Value) {Write-Verbose "Parameter AdminRDSPort doesn't seem to be set.."}
        elseif([String]::Empty -eq $AdminRDSPort) {$Config.AdminRDSPort = $null}
        else{$Config.AdminRDSPort = $AdminRDSPort}

        if($AppID -eq [nullstring]::Value) {Write-Verbose "Parameter AppID doesn't seem to be set.."}
        elseif([String]::Empty -eq $AppID) {$Config.AppID = $null}
        else{$Config.AppID = $AppID}

        if($AppSecret -eq [nullstring]::Value) {Write-Verbose "Parameter AppSecret doesn't seem to be set.."}
        elseif([String]::Empty -eq $AppSecret) {$Config.AppSecret = $null}
        else{$Config.AppSecret = $AppSecret}


        ################
        ### Services ###
        if($Service365 -eq 'True') {
            $Config.Service365 = 'True'
        }
        elseif($Service365 -eq 'False') {
            $Config.Service365 = 'False'
        }
        else{
            $Config.Service365 = $Config.Service365
        }

        if($ServiceCompute -eq 'True') {
            $Config.ServiceCompute = 'True'
        }
        elseif($ServiceCompute -eq 'False') {
            $Config.ServiceCompute = 'False'
        }
        else{
            $Config.ServiceCompute = $Config.ServiceCompute
        }

        if($ServiceIntune -eq 'True') {
            $Config.ServiceIntune = 'True'
        }
        elseif($ServiceIntune -eq 'False') {
            $Config.ServiceIntune = 'False'
        }
        else{
            $Config.ServiceIntune = $Config.ServiceIntune
        }

        Upload-SQLEntConfig -Organization $Organization -Config $Config

    }

}