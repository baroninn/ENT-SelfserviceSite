[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$VMID,

    [Parameter(Mandatory)]
    [string]$VHDID,

    [Parameter(Mandatory)]
    [string]$DateTime,

    [Parameter(Mandatory)]
    [string]$GB,

    [Parameter(Mandatory)]
    [string]$Email,

    [Parameter(Mandatory)]
    [string]$TaskID,

    [switch]$Level25
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

$Cmdlets = @("Get-SCVMMServer", "Get-SCVirtualMachine", "Get-SCVirtualDiskDrive", "Get-SCStorageDisk", "Expand-SCVirtualDiskDrive")

Import-Module (Join-Path $PSScriptRoot Functions)
$Server= 'vmm-a.corp.systemhosting.dk'
$Cred = Get-RemoteCredentials -SSS
Import-Module virtualmachinemanager -Cmdlet $Cmdlets -DisableNameChecking -Force > $null
$SCVMMServer = Get-SCVMMServer -ConnectAs Administrator -ComputerName $Server -Credential $Cred


## Convert VMID back to name
$VMName = Get-SCVirtualMachine -VMMServer $SCVMMServer -ID $VMID | select -ExpandProperty name

$runbookIds = @{
    ExpandVHD   = 0;
}

$runbookIds.ExpandVHD   = '723909bd-a325-432c-84e8-79d911153847'

[int]$GB = $GB

$parameters = @{
    "ExpandByGB" = $GB
    "VMName"     = "$VMName"
    "VhdId"      = "$VHDID"
}

### TEST for freespace on lun ###
$vm = Get-SCVirtualMachine -VMMServer $SCVMMServer -Name $VMName
$Disk = Get-SCVirtualDiskDrive -VM $vm | where{$_.ID.Guid -eq $VHDID}
$vhd = $vm.VirtualHardDisks | where {$_.ID.Guid -eq $Disk.VirtualHardDiskId.Guid}
$volName = $vhd.Directory.Substring(0, $vhd.Directory.LastIndexOf('\'))

$lun = Get-SCStorageDisk | where {$_.DiskVolumes[0] -ne $null -and $_.DiskVolumes[0].ToString() -eq $volName} | select -first 1
$freeSpace = $lun.PhysicallyAvailableCapacity / 1GB
    
$VHDLunInfo = [pscustomobject]@{
                    Freespace              = $freespace
                    VolName                = $volName
                    Disk = [pscustomobject]@{
                        Name = $Disk.Name
                        BusType = $Disk.BusType
                        IsVHD = $Disk.IsVHD
                        ID = $Disk.ID.Guid
                        VHDFormatType = $vhd.VHDFormatType
                        }
                }

$freeSpaceAfter = $VHDLunInfo.Freespace - $parameters["ExpandByGB"]

if ($freeSpaceAfter -lt 100) { # 100 GB
    throw "This will put the lun ($($VHDLunInfo.VolName)) at less than 100GB (currently at " + [int][math]::floor($VHDLunInfo.Freespace) + " GB)"
}

## If possible expand it right away...
if ($VHDLunInfo.Disk.BusType -eq 'SCSI' -and $VHDLunInfo.Disk.VHDFormatType -eq 'VHDX') {

    $vm = Get-SCVirtualMachine -VMMServer $SCVMMServer -Name $VMName
    $Disk = Get-SCVirtualDiskDrive -VM $vm | where{$_.ID.Guid -eq $VHDID}
    $vhd = $vm.VirtualHardDisks | where {$_.ID.Guid -eq $Disk.VirtualHardDiskId.Guid}

    [int]$size = $vhd.MaximumSize / 1024 / 1024 / 1024

    Expand-SCVirtualDiskDrive -VirtualDiskDrive $Disk -VirtualHardDiskSizeGB ($Size + $GB)

    Write-Output "The disk has been expanded on the fly, because..... It can..."
}
else {

    Import-Module (Join-Path $PSScriptRoot OrchestratorHook2.dll)
    $RunbookId = $runbookIds.ExpandVHD

    [datetime]$ConvertTime = "$DateTime"
    $ScheduledTime = $ConvertTime.ToString("yyyy-MM-dd HH:mm:ss")

    $paramString = ""

    foreach ($param in $parameters.Keys) {
        $paramString += "$($param)|1$($parameters[$param])|2"
    }

    $paramString = $paramString.Substring(0, $paramString.Length-2)


    function StartRunbook($EmailStatusTo, $Parameters, $ScheduledTime, $RunbookId, $TaskID) {
        $params = [string]::Format("EmailStatusTo={0}&Parameters={1}&ScheduledTime={2}&RunbookId={3}&Status=Scheduled&TaskID={4}", $EmailStatusTo, $Parameters, $ScheduledTime, $RunbookId, $TaskID)
        $params 

        $hook = New-Object OrchestratorHook2.OrchestratorHook
        $hook.Connect()
        $hook.Run("80f0fe85-c2f6-4603-a1c7-5c96ac12f5cb", $params)
    }

    StartRunbook -EmailStatusTo $Email -Parameters $paramString -ScheduledTime $ScheduledTime -RunbookId $RunbookId -TaskID $TaskID > $null
    Remove-Module OrchestratorHook2 -Force
}

