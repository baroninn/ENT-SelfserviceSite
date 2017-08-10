function New-EntOrganization {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$EmailDomainName,

        [string]$Subnet,
        
        [string]$Vlan,

        [string]$Gateway,
        
        [string]$IPAddressRangeStart,
        
        [string]$IPAddressRangeEnd,
        
        [switch]$CreateVMM


    )

    Begin {
    
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2.0

    }
    Process {

        
        #Add-SQLEntOrganization -Organization $Organization -Name $Name

        New-SQLEntConfig -Organization $Organization -Name $Name

        Set-SQLEntConfig -Organization $Organization -Name $Name -DomainFQDN ("$Organization.$EmailDomainName") -EmailDomains "$EmailDomainName" -DomainDC "$Organization-DC-01.$Organization.$EmailDomainName" -CustomerOUDN "OU=CUSTOMER,DC=$Organization,DC=$($EmailDomainName.Split('.')[0]),DC=$($EmailDomainName.Split('.')[1])" -AdminUserOUDN "OU=Users,OU=Admins,OU=SYSTEMHOSTING,DC=$Organization,DC=$($EmailDomainName.Split('.')[0]),DC=$($EmailDomainName.Split('.')[1])" -ExternalUserOUDN "OU=External,OU=CUSTOMER,DC=$Organization,DC=$($EmailDomainName.Split('.')[0]),DC=$($EmailDomainName.Split('.')[1])" -AADsynced 'False'

        if ($CreateVMM) {
            New-PrivateCloud -Organization $Organization -EmailDomainName $EmailDomainName -Subnet $Subnet -Vlan $Vlan -Gateway $Gateway -IPAddressRangeStart $IPAddressRangeStart -IPAddressRangeEnd $IPAddressRangeEnd
        }

        #New-SCCMCollection -Organization $Organization -FQDN "corp.$($EmailDomainName)"

    }
}