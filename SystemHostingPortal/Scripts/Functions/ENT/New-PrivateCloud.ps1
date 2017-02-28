function New-PrivateCloud {
    [CmdletBinding()]
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

    begin{

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
        
        $Server= 'vmm-a.corp.systemhosting.dk'
    }


    process{

        $ScriptBlock = {
            param($Organization, 
                  $EmailDomainName, 
                  $Subnet, 
                  $Vlan, 
                  $IPAddressRangeStart, 
                  $IPAddressRangeEnd
                  )
            $Server= 'vmm-a.corp.systemhosting.dk'
            $CloudDescription = "$Organization - $EmailDomainName"

            $hostGroups = @()
            $HostGroups += Get-SCVMHostGroup -VMMServer $server -Name "Tier1"
            $HostGroups += Get-SCVMHostGroup -VMMServer $server -Name "Tier2"
            $readonlyLibraryShares = @()
            $readonlyLibraryShares += Get-SCLibraryShare -VMMServer $Server | where {$_.Name -match "VMM-A-Library"}
            $LogicalNetwName = Get-SCLogicalNetwork -Name "VM Traffic" -VMMServer $Server
            $LogicalNetwName1 = Get-SCLogicalNetwork -Name "Service Network" -VMMServer $Server
            $CapabilityProfile = Get-SCCapabilityProfile -Name "Hyper-V" -VMMServer $Server

            $resources = @()
            $resources += $LogicalNetwName
            $resources += $LogicalNetwName1
            $resources += Get-SCPortClassification -Name "Medium bandwidth" -VMMServer $Server
            $resources += Get-SCStorageClassification -Name "Pure SSD" -VMMServer $Server
            $resources += Get-SCStorageClassification -Name "Remote Storage" -VMMServer $Server
            $resources += Get-SCStorageClassification -Name "Compellent01" -VMMServer $Server

            $Cloud = New-SCCloud -Name $CloudDescription -VMHostGroup $hostGroups -VMMServer $Server

            Set-SCCloud -Cloud $Cloud -AddCloudResource $resources -VMMServer $server -AddReadOnlyLibraryShare $readonlyLibraryShares -AddCapabilityProfile $CapabilityProfile
        
            ###### Create Logical Network and IP Scopes ######

            # Get Logical Network 'VM Traffic'

            $subnetVLan = New-SCSubnetVLan -Subnet $Subnet -VLanID $Vlan -VMMServer $Server 
            $hostGroup = @()
            $hostGroup += Get-SCVMHostGroup -ID "8a331b2c-836e-4c0f-8707-47704bb949b2" -VMMServer $Server
            $logicalNetworkDefinition = New-SCLogicalNetworkDefinition -LogicalNetwork $LogicalNetwName -Name "$($Organization) - $Vlan" -SubnetVLan $subnetVLan -VMHostGroup $hostGroup -VMMServer $Server
            $vmNetwork = New-SCVMNetwork -Name "$($Organization) - $Vlan" -LogicalNetwork $LogicalNetwName -IsolationType "VLANNetwork"
            $vmSubnet = New-SCVMSubnet -Name "$($Organization)_0" -LogicalNetworkDefinition $logicalNetworkDefinition -SubnetVLan $subnetVLan -VMNetwork $vmNetwork
            
            $portProfile = Get-SCNativeUplinkPortProfile -ID "223ba653-1780-4c35-8387-10d1b5ca8174"
            Set-SCNativeUplinkPortProfile -NativeUplinkPortProfile $portProfile -AddLogicalNetworkDefinition $logicalNetworkDefinition

            # Network Routes
            $allNetworkRoutes = @()

            # Gateways
            $allGateways = @()

            # DNS servers
            $allDnsServer = @()

            # DNS suffixes
            $allDnsSuffixes = @()

            # WINS servers
            $allWinsServers = @()

            New-SCStaticIPAddressPool -Name "$($Organization) - $Vlan" -LogicalNetworkDefinition $logicalNetworkDefinition -Subnet $Subnet -IPAddressRangeStart $IPAddressRangeStart -IPAddressRangeEnd $IPAddressRangeEnd -DNSServer $IPAddressRangeStart -DNSSuffix "" -DNSSearchSuffix $allDnsSuffixes -NetworkRoute $allNetworkRoutes -RunAsynchronously -VMMServer $Server

            ###### Import service template ######

            $package = Get-SCTemplatePackage -Path "C:\ENT - ServiceTemplateImport.xml"
            $allMappings = New-SCPackageMapping -TemplatePackage $package

            $template = Import-SCTemplate -TemplatePackage $package -Name "Ent Cust - corp.$EmailDomainName" -PackageMapping $allMappings -Release "1.0" -SettingsIncludePrivate

            #$template = Get-SCServiceTemplate "Ent Cust - corp.test1.dk"
            $password = "DIPPEzipper20!5" | ConvertTo-SecureString -asPlainText -Force
            $username = "corp\administrator"
            $credential = New-Object System.Management.Automation.PSCredential($username,$password)
            $runAsAccount = New-SCRunAsAccount -Credential $credential -Name "Ent Cust - $Organization Domain Admin Account" -Description "" -NoValidation

            $kunde = Get-SCServiceSetting -ServiceTemplate $template -Name kunde
            $kundeFQDN = Get-SCServiceSetting -ServiceTemplate $template -Name kundeFQDN
            $kundeNetBios = Get-SCServiceSetting -ServiceTemplate $template -Name kundeNetBios
            $KundeDomainAdmin = Get-SCServiceSetting -ServiceTemplate $template -Name KundeDomainAdmin
            $SafeModeAdminPassword = Get-SCServiceSetting -ServiceTemplate $template -Name SafeModeAdminPassword
            $VMNetworksetting = Get-SCServiceSetting -ServiceTemplate $template -Name vmnetwork

            Set-SCServiceSetting -ServiceSetting $kunde -Value $Organization
            Set-SCServiceSetting -ServiceSetting $kundeFQDN -Value "corp.$EmailDomainName"
            Set-SCServiceSetting -ServiceSetting $kundeNetBios -Value "corp"
            Set-SCServiceSetting -ServiceSetting $KundeDomainAdmin -Value $runAsAccount
            Set-SCServiceSetting -ServiceSetting $SafeModeAdminPassword -IsEncrypted $false
            Set-SCServiceSetting -ServiceSetting $SafeModeAdminPassword -Value "DIPPEzipper20!5"
            Set-SCServiceSetting -ServiceSetting $VMNetworksetting -Value $vmNetwork.ID

            $SCServiceConfiguration = New-SCServiceConfiguration -Name $Organization -ServiceTemplate $template -Cloud $Cloud 

            New-SCService -ServiceConfiguration $SCServiceConfiguration -RunAsynchronously
        }

    Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock -ArgumentList $Organization, $EmailDomainName, $Subnet, $Vlan, $IPAddressRangeStart, $IPAddressRangeEnd

    }
}