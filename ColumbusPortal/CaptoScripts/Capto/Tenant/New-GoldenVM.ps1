function New-GoldenVM {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Solution,

        [switch]$Test
    )

    begin{

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
        $Creds = Get-RemoteCredentials -CPO
        $Server= 'CPO-VMM-01.hosting.capto.dk'
    }

    process{


    if ($Solution -eq "Legal") {

        $ScriptBlock = {
            param(
                $Solution,
                $Test
                )

            Import-Module virtualmachinemanager
            $VMMHost = 'CPO-VMM-01.hosting.capto.dk'

            if (-not $test) {
            $Latest = Get-SCVirtualMachine -VMMServer $VMMHost | where{$_.Name -like "CPOLegalGolden*"} | sort name | select -Last 1 | select -ExpandProperty Name
            try{[int]$int = $Latest.Substring(14)}catch{[int]$int = 0}
            $New = ("CPOLegalGolden" + ($int + 1))
            }

            if ($test) {
            $Latest = Get-SCVirtualMachine -VMMServer $VMMHost | where{$_.Name -like "CPOLegalGolden-TEST*"} | sort name | select -Last 1 | select -ExpandProperty Name
            try{[int]$int = $Latest.Substring(19)}catch{[int]$int = 0}
            $New = ("CPOLegalGolden-TEST" + ($int + 1))
            }

            $VMName = $New
            $JobGroup = [guid]::NewGuid()
            $JobGroup2 = [guid]::NewGuid()

            New-SCVirtualScsiAdapter -VMMServer $VMMHost -JobGroup $JobGroup.Guid -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType 

            if (-not $test) {
            $ISO = Get-SCISO -VMMServer $VMMHost | where {$_.Name -eq "LegalBoot.iso"}
            }

            if ($test) {
            $ISO = Get-SCISO -VMMServer $VMMHost | where {$_.Name -eq "LegalTEST.iso"}
            }

            New-SCVirtualDVDDrive -VMMServer $VMMHost -JobGroup $JobGroup.Guid -Bus 1 -LUN 0 -ISO $ISO 

            #$VMSubnet = Get-SCVMSubnet -VMMServer $VMMHost -Name "CPO Backbone - 246" | where {$_.VMNetwork.ID -eq "a769d834-addb-4686-a024-daf2c4ad3aee"}
            $VMNetwork = Get-SCVMNetwork -VMMServer $VMMHost -Name "CPO Prod - 245" -ID "943f7f3a-df7e-4174-be60-d55c49720f60"
            $PortClassification = Get-SCPortClassification -VMMServer $VMMHost | where {$_.Name -eq "Medium bandwidth"}

            New-SCVirtualNetworkAdapter -VMMServer $VMMHost -JobGroup $JobGroup.Guid -MACAddressType Dynamic -Synthetic -IPv4AddressType Dynamic -IPv6AddressType Dynamic -VLanEnabled $false -VMNetwork $VMNetwork -PortClassification $PortClassification 

            Set-SCVirtualCOMPort -NoAttach -VMMServer $VMMHost -GuestPort 1 -JobGroup $JobGroup.Guid
            Set-SCVirtualCOMPort -NoAttach -VMMServer $VMMHost -GuestPort 2 -JobGroup $JobGroup.Guid
            Set-SCVirtualFloppyDrive -RunAsynchronously -VMMServer $VMMHost -NoMedia -JobGroup $JobGroup.Guid

            $CPUType = Get-SCCPUType -VMMServer $VMMHost | where {$_.Name -eq "3.60 GHz Xeon (2 MB L2 cache)"}
            $CapabilityProfile = Get-SCCapabilityProfile -VMMServer $VMMHost | where {$_.Name -eq "Hyper-V"}

            New-SCVirtualDiskDrive -VMMServer $VMMHost -IDE -Bus 0 -LUN 0 -JobGroup $JobGroup2.Guid -VirtualHardDiskSizeMB 81920 -CreateDiffDisk $false -Dynamic -Filename "$($VMName)_disk_1_OSDisk" -VolumeType BootAndSystem

            $HardwareProfile = Get-SCHardwareProfile -VMMServer $VMMHost | where {$_.Name -eq "CPO RDS - GoldenImage"}

            if (-not $test) {
            $template = Get-SCVMTemplate -All | where { $_.Name -eq "CPO Legal VMTemplate" }
            }

            if ($test) {
            $template = Get-SCVMTemplate -All | where { $_.Name -eq "CPO Legal VMTemplate - TEST" }
            }

            $virtualMachineConfiguration = New-SCVMConfiguration -VMTemplate $template -Name $VMName
            Write-Verbose $virtualMachineConfiguration
            $cloud = Get-SCCloud -Name "CPO - Prod"
            New-SCVirtualMachine -Name $VMName -VMConfiguration $virtualMachineConfiguration -Cloud $cloud -Description "" -JobGroup $JobGroup2.Guid -ReturnImmediately -StartAction "AlwaysAutoTurnOnVM" -StopAction "SaveVM" -StartVM
            }
        Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock -ArgumentList $Solution, $Test -Credential $Creds
        }

    if ($Solution -eq "AdvoPlus") {

        $ScriptBlock = {
            param(
                $Solution,
                $Test
                )

            Import-Module virtualmachinemanager
            $VMMHost = 'CPO-VMM-01.hosting.capto.dk'

            if (-not $test) {
            $Latest = Get-SCVirtualMachine -VMMServer $VMMHost | where{$_.Name -like "CPOAdvoGolden*"} | sort name | select -Last 1 | select -ExpandProperty Name
            try{[int]$int = $Latest.Substring(13)}catch{[int]$int = 0}
            $New = ("CPOAdvoGolden" + ($int + 1))
            }

            if ($test) {
            $Latest = Get-SCVirtualMachine -VMMServer $VMMHost | where{$_.Name -like "CPOAdvoGolden-TEST*"} | sort name | select -Last 1 | select -ExpandProperty Name
            try{[int]$int = $Latest.Substring(18)}catch{[int]$int = 0}
            $New = ("CPOAdvoGolden-TEST" + ($int + 1))
            }

            $VMName = $New
            $JobGroup = [guid]::NewGuid()
            $JobGroup2 = [guid]::NewGuid()

            New-SCVirtualScsiAdapter -VMMServer $VMMHost -JobGroup $JobGroup.Guid -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType 

            if (-not $test) {
            $ISO = Get-SCISO -VMMServer $VMMHost | where {$_.Name -eq "AdvoBoot.iso"}
            }

            if ($test) {
            $ISO = Get-SCISO -VMMServer $VMMHost | where {$_.Name -eq "AdvoTEST.iso"}
            }

            New-SCVirtualDVDDrive -VMMServer $VMMHost -JobGroup $JobGroup.Guid -Bus 1 -LUN 0 -ISO $ISO 

            #$VMSubnet = Get-SCVMSubnet -VMMServer $VMMHost -Name "CPO Backbone - 246_0" | where {$_.VMNetwork.ID -eq "4574f690-2ec4-4b1f-8a40-d607c3e80927"}
            $VMNetwork = Get-SCVMNetwork -VMMServer $VMMHost -Name "CPO Prod - 245" -ID "943f7f3a-df7e-4174-be60-d55c49720f60"
            $PortClassification = Get-SCPortClassification -VMMServer $VMMHost | where {$_.Name -eq "Medium bandwidth"}

            New-SCVirtualNetworkAdapter -VMMServer $VMMHost -JobGroup $JobGroup.Guid -MACAddressType Dynamic -Synthetic -IPv4AddressType Dynamic -IPv6AddressType Dynamic -VLanEnabled $false -VMNetwork $VMNetwork -PortClassification $PortClassification 

            Set-SCVirtualCOMPort -NoAttach -VMMServer $VMMHost -GuestPort 1 -JobGroup $JobGroup.Guid
            Set-SCVirtualCOMPort -NoAttach -VMMServer $VMMHost -GuestPort 2 -JobGroup $JobGroup.Guid
            Set-SCVirtualFloppyDrive -RunAsynchronously -VMMServer $VMMHost -NoMedia -JobGroup $JobGroup.Guid

            $CPUType = Get-SCCPUType -VMMServer $VMMHost | where {$_.Name -eq "3.60 GHz Xeon (2 MB L2 cache)"}
            $CapabilityProfile = Get-SCCapabilityProfile -VMMServer $VMMHost | where {$_.Name -eq "Hyper-V"}

            ## Create disks..
            New-SCVirtualDiskDrive -VMMServer $VMMHost -IDE -Bus 0 -LUN 0 -JobGroup $JobGroup2.Guid -VirtualHardDiskSizeMB 81920 -CreateDiffDisk $false -Dynamic -Filename "$($VMName)_disk_1_OSDisk" -VolumeType BootAndSystem

            $HardwareProfile = Get-SCHardwareProfile -VMMServer $VMMHost | where {$_.Name -eq "CPO RDS - GoldenImage"}

            if (-not $test) {
            $template = Get-SCVMTemplate -All | where { $_.Name -eq "CPO Advo VMTemplate" }
            }

            if ($test) {
            $template = Get-SCVMTemplate -All | where { $_.Name -eq "CPO Advo VMTemplate - TEST" }
            }

            $virtualMachineConfiguration = New-SCVMConfiguration -VMTemplate $template -Name $VMName
            Write-Verbose $virtualMachineConfiguration
            $cloud = Get-SCCloud -Name "CPO - Prod"
            New-SCVirtualMachine -Name $VMName -VMConfiguration $virtualMachineConfiguration -Cloud $cloud -Description "" -JobGroup $JobGroup2.Guid -ReturnImmediately -StartAction "AlwaysAutoTurnOnVM" -StopAction "SaveVM" -StartVM
            }
        Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock -ArgumentList $Solution, $Test -Credential $Creds
        }

    if ($Solution -eq "Member2015") {

        $ScriptBlock = {
            param(
                $Solution,
                $Test
                )

            Import-Module virtualmachinemanager
            $VMMHost = 'CPO-VMM-01.hosting.capto.dk'

            if (-not $test) {
                $Latest = Get-SCVirtualMachine -VMMServer $VMMHost | where{$_.Name -like "CPOMember2015Golden*"} | sort name | select -Last 1 | select -ExpandProperty Name
            try{[int]$int = $Latest.Substring(13)}catch{[int]$int = 0}
                $New = ("CPOMember2015Golden" + ($int + 1))
            }

            if ($test) {
                $Latest = Get-SCVirtualMachine -VMMServer $VMMHost | where{$_.Name -like "CPOMember2015Golden-TEST*"} | sort name | select -Last 1 | select -ExpandProperty Name
            try{[int]$int = $Latest.Substring(18)}catch{[int]$int = 0}
                $New = ("CPOMember2015Golden-TEST" + ($int + 1))
            }

            $VMName = $New
            $JobGroup = [guid]::NewGuid()
            $JobGroup2 = [guid]::NewGuid()

            New-SCVirtualScsiAdapter -VMMServer $VMMHost -JobGroup $JobGroup.Guid -AdapterID 7 -ShareVirtualScsiAdapter $false -ScsiControllerType DefaultTypeNoType 

            if (-not $test) {
                $ISO = Get-SCISO -VMMServer $VMMHost | where {$_.Name -eq "MemberBoot.iso"}
            }

            if ($test) {
                $ISO = Get-SCISO -VMMServer $VMMHost | where {$_.Name -eq "MemberTEST.iso"}
            }

            New-SCVirtualDVDDrive -VMMServer $VMMHost -JobGroup $JobGroup.Guid -Bus 1 -LUN 0 -ISO $ISO 

            #$VMSubnet = Get-SCVMSubnet -VMMServer $VMMHost -Name "CPO Backbone - 246_0" | where {$_.VMNetwork.ID -eq "4574f690-2ec4-4b1f-8a40-d607c3e80927"}
            $VMNetwork = Get-SCVMNetwork -VMMServer $VMMHost -Name "CPO Prod - 245" -ID "943f7f3a-df7e-4174-be60-d55c49720f60"
            $PortClassification = Get-SCPortClassification -VMMServer $VMMHost | where {$_.Name -eq "Medium bandwidth"}

            New-SCVirtualNetworkAdapter -VMMServer $VMMHost -JobGroup $JobGroup.Guid -MACAddressType Dynamic -Synthetic -IPv4AddressType Dynamic -IPv6AddressType Dynamic -VLanEnabled $false -VMNetwork $VMNetwork -PortClassification $PortClassification 

            Set-SCVirtualCOMPort -NoAttach -VMMServer $VMMHost -GuestPort 1 -JobGroup $JobGroup.Guid
            Set-SCVirtualCOMPort -NoAttach -VMMServer $VMMHost -GuestPort 2 -JobGroup $JobGroup.Guid
            Set-SCVirtualFloppyDrive -RunAsynchronously -VMMServer $VMMHost -NoMedia -JobGroup $JobGroup.Guid

            $CPUType = Get-SCCPUType -VMMServer $VMMHost | where {$_.Name -eq "3.60 GHz Xeon (2 MB L2 cache)"}
            $CapabilityProfile = Get-SCCapabilityProfile -VMMServer $VMMHost | where {$_.Name -eq "Hyper-V"}

            ## Create disks..
            New-SCVirtualDiskDrive -VMMServer $VMMHost -IDE -Bus 0 -LUN 0 -JobGroup $JobGroup2.Guid -VirtualHardDiskSizeMB 81920 -CreateDiffDisk $false -Dynamic -Filename "$($VMName)_disk_1_OSDisk" -VolumeType BootAndSystem

            $HardwareProfile = Get-SCHardwareProfile -VMMServer $VMMHost | where {$_.Name -eq "CPO RDS - GoldenImage"}

            if (-not $test) {
                $template = Get-SCVMTemplate -All | where { $_.Name -eq "CPO Member VMTemplate" }
            }

            if ($test) {
                $template = Get-SCVMTemplate -All | where { $_.Name -eq "CPO Member VMTemplate - TEST" }
            }

            $virtualMachineConfiguration = New-SCVMConfiguration -VMTemplate $template -Name $VMName
            Write-Verbose $virtualMachineConfiguration
            $cloud = Get-SCCloud -Name "CPO - Prod"
            New-SCVirtualMachine -Name $VMName -VMConfiguration $virtualMachineConfiguration -Cloud $cloud -Description "" -JobGroup $JobGroup2.Guid -ReturnImmediately -StartAction "AlwaysAutoTurnOnVM" -StopAction "SaveVM" -StartVM
            }
        Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock -ArgumentList $Solution, $Test -Credential $Creds
        }

    }
}