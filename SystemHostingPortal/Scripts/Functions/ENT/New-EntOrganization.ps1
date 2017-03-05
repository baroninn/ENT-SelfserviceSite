function New-EntOrganization {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$EmailDomainName,

        [Parameter(Mandatory)]
        [string]$Subnet,

        [Parameter(Mandatory)]
        [string]$Vlan,
        
        [Parameter(Mandatory)]
        [string]$IPAddressRangeStart,

        [Parameter(Mandatory)]
        [string]$IPAddressRangeEnd
    )

    Begin {
    
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2.0

    }
    Process {
    
        New-EntConfig -Organization $Organization

        Set-EntConfig -Organization $Organization -DomainFQDN ("corp.$EmailDomainName")

        New-PrivateCloud -Organization $Organization -EmailDomainName $EmailDomainName -Subnet $Subnet -Vlan $Vlan -IPAddressRangeStart $IPAddressRangeStart -IPAddressRangeEnd $IPAddressRangeEnd

        #New-SCCMCollection -Organization $Organization -FQDN "corp.$($EmailDomainName)"

    }
}