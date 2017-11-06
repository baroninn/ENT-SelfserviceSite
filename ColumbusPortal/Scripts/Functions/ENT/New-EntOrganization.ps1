function New-EntOrganization {
    <#
    .SYNOPSIS
        Create a new organization, with optional Crayon tenant associated


    .EXAMPLE
        New-EntOrganization <all params>

    .NOTES
    Author:      Jakob Strøm
    Contact:     jst@columbusglobal.com
    Created:     2017-10-21
    #>
    [Cmdletbinding(DefaultParametersetName='None')]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [string]$Platform,

        [Parameter(Mandatory)]
        [string]$EmailDomainName,

        [Parameter(ParameterSetName='VMM', Mandatory=$false)]
        [switch]$CreateVMM,

        [Parameter(ParameterSetName='VMM', Mandatory=$true)]
        [string]$Subnet,
        
        [Parameter(ParameterSetName='VMM', Mandatory=$true)]
        [string]$Vlan,

        [Parameter(ParameterSetName='VMM', Mandatory=$true)]
        [string]$Gateway,
        
        [Parameter(ParameterSetName='VMM', Mandatory=$true)]
        [string]$IPAddressRangeStart,
        
        [Parameter(ParameterSetName='VMM', Mandatory=$true)]
        [string]$IPAddressRangeEnd,

        [Parameter(ParameterSetName='Crayon', Mandatory=$false)]
        [switch]$createcrayon,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$InvoiceProfile,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonDomainPrefix,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonFirstName,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonLastName,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonEmail,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonPhoneNumber,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonCustomerFirstName,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonCustomerLastName,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonAddressLine1,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonCity,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonRegion,

        [Parameter(ParameterSetName='Crayon', Mandatory=$true)]
        [string]$CrayonPostalCode


    )

    Begin {
    
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

    }
    Process {
        
        if ($Platform -eq "Enterprise" -or $Platform -eq "Hybrid") {
            if (-not $CreateVMM) {
                New-SQLEntConfig -Organization $Organization -Name $Name
                Set-SQLEntConfig -Organization $Organization -Name $Name -Platform $Platform -DomainFQDN ("$Organization.$EmailDomainName") -EmailDomains ("$Organization.$EmailDomainName")
            }
            elseif ($CreateVMM) {
                New-SQLEntConfig -Organization $Organization -Name $Name
                Set-SQLEntConfig -Organization $Organization -Name $Name -Platform $Platform -DomainFQDN ("$Organization.$EmailDomainName") -EmailDomains ("$Organization.$EmailDomainName") -DomainDC "$Organization-DC-01.$Organization.$EmailDomainName" -UserContainer "OU=Users,OU=CUSTOMER,DC=$Organization,DC=$($EmailDomainName.Split('.')[0]),DC=$($EmailDomainName.Split('.')[1])" -CustomerOUDN "OU=CUSTOMER,DC=$Organization,DC=$($EmailDomainName.Split('.')[0]),DC=$($EmailDomainName.Split('.')[1])" -AdminUserOUDN "OU=Users,OU=Admins,OU=COLUMBUS,DC=$Organization,DC=$($EmailDomainName.Split('.')[0]),DC=$($EmailDomainName.Split('.')[1])" -ExternalUserOUDN "OU=External,OU=CUSTOMER,DC=$Organization,DC=$($EmailDomainName.Split('.')[0]),DC=$($EmailDomainName.Split('.')[1])" -AADsynced 'False' -AdminRDS "adminrds.systemhosting.dk" -AdminRDSPort "60$($Vlan)"
            }
        }
        elseif ($Platform -eq "Cloud") {

            New-SQLEntConfig -Organization $Organization -Name $Name
            Set-SQLEntConfig -Organization $Organization -Name $Name -Platform $Platform -DomainFQDN ("$EmailDomainName") -EmailDomains "$EmailDomainName"
        }

        if ($CreateVMM) {
            New-PrivateCloud -Organization $Organization -EmailDomainName $EmailDomainName -Subnet $Subnet -Vlan $Vlan -Gateway $Gateway -IPAddressRangeStart $IPAddressRangeStart -IPAddressRangeEnd $IPAddressRangeEnd
            
            try {

                if (-not (Get-DnsServerZone -ComputerName "DC-01.corp.systemhosting.dk" -Name ("$Organization.$EmailDomainName") -ErrorAction SilentlyContinue)) {
                    Add-DnsServerConditionalForwarderZone -Name ("$Organization.$EmailDomainName") -ReplicationScope Forest -ComputerName "DC-01.corp.systemhosting.dk" -MasterServers $IPAddressRangeStart
                }
                $Password = "DRAPPLEdipper831"
                $secPass = ConvertTo-SecureString -String $Password -AsPlainText -Force
                $username = "soedns-01\administrator" 
                $cred = New-Object System.Management.Automation.PSCredential($username,$secPass)

                $cim = New-CimSession -ComputerName "10.16.4.254" -Credential $cred

                if (-not (Get-DnsServerZone -Name ("$Organization.$EmailDomainName") -CimSession $cim -ErrorAction SilentlyContinue)) {
                    Add-DnsServerConditionalForwarderZone -Name ("$Organization.$EmailDomainName") -MasterServers $IPAddressRangeStart -CimSession $cim > $null
                }
                $cim | Remove-CimSession
            }
            catch {
                throw "DNS add error: $($_.Exception), please add the condionalforwarders manually in CORP and on soedns-01"
            }
        }

        if ($createcrayon) {
            try {
                $Header = Get-CrayonAPIToken
                $Tenant = New-CrayonTenant -Header $Header -Name $Name -Reference $Organization -DomainPrefix $CrayonDomainPrefix -InvoiceProfile $InvoiceProfile -FirstName $CrayonFirstName -LastName $CrayonLastName -Email $CrayonEmail -PhoneNumber $CrayonPhoneNumber -CustomerFirstName $CrayonCustomerFirstName -CustomerLastName $CrayonCustomerLastName -AddressLine1 $CrayonAddressLine1 -City $CrayonCity -Region $CrayonRegion -PostalCode $CrayonPostalCode
            
                Set-SQLEntConfig -Organization $Organization -TenantID $Tenant.ExternalPublisherCustomerId -AdminUser $Tenant.AdminUser -AdminPass $Tenant.AdminPass

                $NewTenant = [pscustomobject]@{
                    Id = $Tenant.Tenant.Id
                    Name = $Tenant.Tenant.Name
                    PublisherCustomerId = $Tenant.Tenant.PublisherCustomerId
                    ExternalPublisherCustomerId = $Tenant.Tenant.ExternalPublisherCustomerId
                    DomainPrefix = $Tenant.Tenant.DomainPrefix
                    Reference = $Tenant.Tenant.Reference
                    AdminUser = $Tenant.User.UserName
                    AdminPass = $Tenant.User.Password
                }
                $NewTenant
            }
            catch {
                throw $_
            }
        }
    }
}