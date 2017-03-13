function New-EntOrganization {
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$EmailDomainName,

        [string]$Subnet,
        
        [string]$Vlan,
        
        [string]$IPAddressRangeStart,
        
        [string]$IPAddressRangeEnd,
        


    )

    Begin {
    
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2.0

    }
    Process {

    
        New-EntConfig -Organization $Organization

        Set-EntConfig -Organization $Organization -DomainFQDN ("corp.$EmailDomainName")

        if ($CreateVMM) {
            New-PrivateCloud -Organization $Organization -EmailDomainName $EmailDomainName -Subnet $Subnet -Vlan $Vlan -IPAddressRangeStart $IPAddressRangeStart -IPAddressRangeEnd $IPAddressRangeEnd
        }

        #New-SCCMCollection -Organization $Organization -FQDN "corp.$($EmailDomainName)"

    }
}