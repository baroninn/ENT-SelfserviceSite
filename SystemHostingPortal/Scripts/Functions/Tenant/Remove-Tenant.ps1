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

        $errors = @()

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

            try {
                sc.exe ("\\" + $Config.NAVInstanceServer.Fqdn) delete ("MicrosoftDynamicsNavWS$" + $TenantName)
                sc.exe ("\\" + $Config.NAVInstanceServer.Fqdn) stop ("MicrosoftDynamicsNavWS$" + $TenantName)
            }
            catch {
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

        # Get file server properties.
        $ou = "OU=$TenantName,OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
        $json = (Get-ADOrganizationalUnit -Server $Config.DomainFQDN -Identity $ou -Properties adminDescription).adminDescription
        $obj = ConvertFrom-Json -InputObject $json

        if ($RemoveData) {

            $Driveletter = $obj.FileServer.DriveLetter

            Get-Item -Path ("\\" + $config.FileServer.Fqdn + "\$Driveletter" + "$\Data\" + $TenantName) | Remove-Item -Recurse -Force

        }

        Write-Verbose "Removing 'Protect From Accidental Deletion' from OU"
        Get-ADOrganizationalUnit -Server hosting.capto.dk $Config.OUs.path[1] | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false -ErrorAction SilentlyContinue
        
        Write-Verbose "Removing OU including all objects..."
        Get-ADOrganizationalUnit -Server hosting.capto.dk $Config.OUs.path[1] | Remove-ADOrganizationalUnit -Recursive -Confirm:$false -ErrorAction SilentlyContinue

        start-sleep 25
        Write-Verbose "Removing address book policy..."
            if($bookpolicys = Get-AddressBookPolicy -Identity $TenantName -ErrorAction SilentlyContinue){
                $bookpolicys | Remove-AddressBookPolicy -Confirm:$false -ErrorAction SilentlyContinue}
                else{
                     Write-Verbose "Couldn't find any AddressBookPolicies"
        }

        Write-Verbose "Removing email address policy..."
            if($Addresspolicies = Get-EmailAddressPolicy -Identity $TenantName -ErrorAction SilentlyContinue){
                $Addresspolicies | Remove-EmailAddressPolicy -Confirm:$false}
                else{
                     Write-Verbose "Couldn't find any policies"
        }
        
        Write-Verbose "Removing accepted domains..."
            if($Accepteddomains = Get-TenantAcceptedDomain -TenantName $TenantName -ErrorAction SilentlyContinue){
                $Accepteddomains | Remove-AcceptedDomain -Confirm:$false}
                else{
                     Write-Verbose "Couldn't find any accepted domains"
        }

        Write-Verbose "Remove offline address book..."
            if($offlinebook = Get-OfflineAddressBook -Identity $TenantName -ErrorAction SilentlyContinue){
                $offlinebook | Remove-OfflineAddressBook -Confirm:$false}
                else{
                     Write-Verbose "Couldn't find any OfflineAddressBook"
        }

        Write-Verbose "Removing address lists..."
            if($addresslists = Get-AddressList -Identity "$TenantName *" -ErrorAction SilentlyContinue){
                $addresslists | Remove-AddressList -Confirm:$false}
                else{
                     Write-Verbose "Couldn't find any addresslists"
        }

        Write-Verbose "Removing global address list..."
            if($Globaladdresslist = Get-GlobalAddressList -Identity $TenantName -ErrorAction SilentlyContinue){
                $Globaladdresslist | Remove-GlobalAddressList -Confirm:$false}
                else{
                     Write-Verbose "Couldn't find any addresslists"
        }

        Write-Verbose "Removing GPO's..."
        Get-GPO -Domain hosting.capto.dk -All | where DisplayName -like "$($TenantName)_*" | Remove-GPO -Domain hosting.capto.dk -ErrorAction SilentlyContinue

        Write-Verbose "Removing SMB shares..."
            if($SMBShare = Get-SmbShare -CimSession $Config.FileServer.Fqdn -Name "Share_$($TenantName)_*" -ErrorAction SilentlyContinue){
                $SMBShare | Remove-SmbShare -Confirm:$false -ErrorAction SilentlyContinue}
                else{
                     Write-Verbose "Couldn't find SMBShare"
        }

        Write-Verbose "Removing quotas..."
            if($FSRMQuotas = Get-FSRMQuota -CimSession $Config.FileServer.Fqdn -Path ($Config.FileServer.DataPath + "\$TenantName") -ErrorAction SilentlyContinue){
                $FSRMQuotas | Remove-FsrmQuota -Confirm:$false -ErrorAction SilentlyContinue}
                else{
                     Write-Verbose "Couldn't find FSRMQuotas"
        }
        
        Write-Verbose "Removing DFS folders..."
            if($DFSNFolder = Get-DfsnFolder -Path "\\capto\data\$($TenantName)_*" -ErrorAction SilentlyContinue){
                $DFSNFolder | Remove-DfsnFolder -Force -ErrorAction SilentlyContinue}
                else{
                     Write-Verbose "Couldn't find DFSNfolder"
        }

        Write-Verbose "Removing DNS record..."
        if($DNSRecord = Get-DnsServerResourceRecord -ComputerName $Config.SelfServicePSEndpoint -Name $TenantName -ZoneName $config.DomainFQDN -ErrorAction SilentlyContinue){
                $DNSRecord | Remove-DnsServerResourceRecord -ZoneName $config.DomainFQDN -ComputerName $Config.SelfServicePSEndpoint -Confirm:$false -Force -ErrorAction SilentlyContinue}
                else{
                     Write-Verbose "Couldn't find DFSNfolder"
        }

    }
}