function New-EntOrganization {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

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

    
        New-EntConfig -Organization $Organization

        Set-EntConfig -Organization $Organization -DomainFQDN ("$Organization.$EmailDomainName") -Domains "$EmailDomainName" -DomainDC "$Organization.DC-01.$Organization.$EmailDomainName" -CustomerOUDN "OU=CUSTOMER,DC=$Organization,DC=$($EmailDomainName.Split('.')[0]),DC=$($EmailDomainName.Split('.')[1])"

        if ($CreateVMM) {
            New-PrivateCloud -Organization $Organization -EmailDomainName $EmailDomainName -Subnet $Subnet -Vlan $Vlan -Gateway $Gateway -IPAddressRangeStart $IPAddressRangeStart -IPAddressRangeEnd $IPAddressRangeEnd
        }

        #New-SCCMCollection -Organization $Organization -FQDN "corp.$($EmailDomainName)"

    }
}