function Remove-Tenant {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TenantName,

        [switch]$RemoveData
    )

    Begin {
    }

    Process {

        Import-Module (New-ExchangeProxyModule -Command * -WarningAction SilentlyContinue)

        $config = Get-TenantConfig -TenantName $TenantName
        [pscredential]$RemoteCredential = Get-RemoteCredentials -CPO

        $errors = @()

        # Get file server properties.
        $ou = "OU=$TenantName,OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
        $json = (Get-ADOrganizationalUnit -Server $Config.DomainFQDN -Identity $ou -Properties adminDescription).adminDescription
        $obj = ConvertFrom-Json -InputObject $json

        if ($RemoveData) {

            $Driveletter = $obj.FileServer.DriveLetter
                $Sb= {
                    param($Driveletter, $TenantName)

                    $ErrorActionPreference = 'stop'

                    $Data = Get-Item -Path ("$Driveletter" + ":\Data\" + $TenantName)
                    robocopy C:\DontDelete "$Data" /purge | out-null
                    Start-Sleep 60
                    $Data | Remove-Item -Recurse -Force

                }

            try{
                Invoke-Command -ComputerName ($obj.FileServer.Name + ".hosting.capto.dk") -ScriptBlock $Sb -ArgumentList $Driveletter, $TenantName -Credential $RemoteCredential -Authentication Credssp
            }
            catch {
                Get-Item "\\$($obj.FileServer.Name)\$Driveletter$\Data\$TenantName" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            }

        }

        if ($Config.Product.Name -eq "AdvoPlus") {
            $webserviceParams = @{
                TenantName  = $Config.Name
                CompanyName = 'Remove'
                WebServicePath    = $Config.RepositoryServer.WebServicePath 
                WebServiceLogPath = $Config.RepositoryServer.WebServiceLogPath 
                LogWriter    = $Config.Name
                ComputerName = $Config.RepositoryServer.Fqdn
                Remove       = $True
            }

            try {
                New-AdvoPlusWebServiceInstance @webserviceParams
            }
            catch {
                Write-Error ($_)
            }

            try {
                New-AdvoPlusMobileServerInstance -TenantName $Config.Name -CompanyName 'Remove' -ComputerName $Config.MobileServer.Fqdn -Remove $True
            }
            catch {
                Write-Error ($_)
            }

            Write-Verbose "Trying to remove Service and files on CPO-NST-01.."
                $NSTblock = {
                    param($TenantName)

                    sc.exe delete ("MicrosoftDynamicsNavWS$" + $TenantName)
                    sc.exe stop ("MicrosoftDynamicsNavWS$" + $TenantName)
                    try {
                        Start-Sleep 5
                        $Item = Get-Item "C:\Program Files (x86)\Microsoft Dynamics NAV\60\Service\$TenantName" -ErrorAction SilentlyContinue
                        $Item | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                    }
                    catch {
                        Write-Verbose $_
                    }

                }

            try {
                Invoke-Command -ComputerName $Config.NAVInstanceServer.Fqdn -ScriptBlock $NSTblock -Credential $RemoteCredential -ArgumentList $TenantName -Authentication Credssp
            }
            catch {
                Get-Item "\\$($Config.NAVInstanceServer.Fqdn)\C$\Program Files (x86)\Microsoft Dynamics NAV\60\Service\$TenantName" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Write-Verbose ($_)
            }

            try{
                Remove-AdvoPlusWindowsFirewallRules -TenantName $TenantName -ComputerName $Config.NAVInstanceServer.Fqdn
            }
            catch{
                Write-Error ($_)
            }
        }

        if ($Config.Product.Name -eq "Legal") {
            $webserviceParams = @{
                TenantName  = $Config.Name
                CompanyName = $Config.Name
                WebServicePath    = $Config.RepositoryServer.WebServicePath 
                WebServiceLogPath = $Config.RepositoryServer.WebServiceLogPath 
                LogWriter    = $Config.Name
                ComputerName = $Config.RepositoryServer.Fqdn
                Remove       = $True
            }

            try {
                New-LegalWebServiceInstance @webserviceParams
            }
            catch {
                Write-Error ($_)
            }

            try {
                New-LegalMobileServerInstance -TenantName $Config.Name -CompanyName $Config.Name -ComputerName $Config.MobileServer.Fqdn -Remove $True
            }
            catch {
                Write-Error ($_)
            }
        }

        if ($Config.Product.Name -eq "Legal") {
        $scriptblock = {
        param (
               [string]$TenantName
               )
                Import-Module "C:\Program Files\Microsoft Dynamics NAV\90\Service\NavAdminToolCapto.ps1" | Out-Null
                Remove-NAVServerInstance -ServerInstance $TenantName -Confirm:$false -Force
                #Remove-Item "C:\ProgramData\Microsoft\Microsoft Dynamics NAV\90\Server\MicrosoftDynamicsNavServer$($TenantName)" -Force
                }
        try{
            Write-Verbose ("Removing NAV instance on " + $Config.NAVInstanceServer.fqdn)
            Invoke-Command -ComputerName $Config.NAVInstanceServer.fqdn -ScriptBlock $scriptblock -ArgumentList $TenantName
            }
            catch{}
        }

        Write-Verbose "Removing 'Protect From Accidental Deletion' from OU"
        Get-ADOrganizationalUnit -Server hosting.capto.dk $Config.OUs.path[1] | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
        
        Write-Verbose "Removing OU including all objects..."
        Get-ADOrganizationalUnit -Server hosting.capto.dk $Config.OUs.path[1] | Remove-ADOrganizationalUnit -Recursive -Confirm:$false -ErrorAction SilentlyContinue

        start-sleep 25
        Write-Verbose "Removing address book policy..."
            if($bookpolicys = Get-AddressBookPolicy -Identity $TenantName -ErrorAction SilentlyContinue){
                try{$bookpolicys | Remove-AddressBookPolicy -Confirm:$false}catch{}
                }
                else{
                     Write-Verbose "Couldn't find any AddressBookPolicies"
        }

        Write-Verbose "Removing email address policy..."
            if($Addresspolicies = Get-EmailAddressPolicy -Identity $TenantName -ErrorAction SilentlyContinue){
                try{$Addresspolicies | Remove-EmailAddressPolicy -Confirm:$false}catch{}
                }
                else{
                     Write-Verbose "Couldn't find any policies"
        }
        
        Write-Verbose "Removing accepted domains..."
            if($Accepteddomains = Get-TenantAcceptedDomain -TenantName $TenantName -ErrorAction SilentlyContinue){
                try{$Accepteddomains | Remove-AcceptedDomain -Confirm:$false}catch{}
                }
                else{
                     Write-Verbose "Couldn't find any accepted domains"
        }

        Write-Verbose "Remove offline address book..."
            if($offlinebook = Get-OfflineAddressBook -Identity $TenantName -ErrorAction SilentlyContinue){
                try{$offlinebook | Remove-OfflineAddressBook -Confirm:$false}catch{}
                }
                else{
                     Write-Verbose "Couldn't find any OfflineAddressBook"
        }

        Write-Verbose "Removing address lists..."
            if($addresslists = Get-AddressList -Identity "$TenantName *" -ErrorAction SilentlyContinue){
                try{$addresslists | Remove-AddressList -Confirm:$false}catch{}
                }
                else{
                     Write-Verbose "Couldn't find any addresslists"
        }

        Write-Verbose "Removing global address list..."
            if($Globaladdresslist = Get-GlobalAddressList -Identity $TenantName -ErrorAction SilentlyContinue){
                try{$Globaladdresslist | Remove-GlobalAddressList -Confirm:$false}catch{}
                }
                else{
                     Write-Verbose "Couldn't find any addresslists"
        }

        Write-Verbose "Removing GPO's..."

            $sb = {
                param($TenantName)
                Get-GPO -Domain hosting.capto.dk -All | where DisplayName -like "$($TenantName)_GPO_*" | Remove-GPO -Domain hosting.capto.dk -Confirm:$false
            }

        Invoke-Command -ComputerName $Config.SelfServicePSEndpoint -ScriptBlock $sb -Credential $RemoteCredential -ArgumentList $TenantName

        Write-Verbose "Removing SMB shares..."
            if($SMBShare = Get-SmbShare -CimSession $Config.FileServer.Fqdn -Name "Share_$($TenantName)_*" -ErrorAction SilentlyContinue){
                try{$SMBShare | Remove-SmbShare -Confirm:$false}catch{}
                }
                else{
                     Write-Verbose "Couldn't find SMBShare"
        }

        Write-Verbose "Removing quotas..."
            if($FSRMQuotas = Get-FSRMQuota -CimSession $Config.FileServer.Fqdn -Path ($Config.FileServer.DataPath + "\$TenantName") -ErrorAction SilentlyContinue){
                try{$FSRMQuotas | Remove-FsrmQuota -Confirm:$false}catch{}
                }
                else{
                     Write-Verbose "Couldn't find FSRMQuotas"
        }
        
        Write-Verbose "Removing DFS folders..."
            if($DFSNFolder = Get-DfsnFolder -Path "\\capto\data\$($TenantName)_*" -ErrorAction SilentlyContinue){
                try{$DFSNFolder | Remove-DfsnFolder -Force}catch{}
                }
                else{
                     Write-Verbose "Couldn't find DFSNfolder"
        }

        Write-Verbose "Removing DNS record..."
        if($DNSRecord = Get-DnsServerResourceRecord -ComputerName $Config.SelfServicePSEndpoint -Name $TenantName -ZoneName $config.DomainFQDN -ErrorAction SilentlyContinue){
                try{$DNSRecord | Remove-DnsServerResourceRecord -ZoneName $config.DomainFQDN -ComputerName $Config.SelfServicePSEndpoint -Confirm:$false -Force}catch{}
                }
                else{
                     Write-Verbose "Couldn't find DFSNfolder"
        }

    }
}