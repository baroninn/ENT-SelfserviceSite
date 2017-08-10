function Get-VMVHD {
    [Cmdletbinding()]
    param (
        [string]$VMID,
        [string]$Level30
    )
    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2
        $Server= 'vmm-a.corp.systemhosting.dk'
        $Cmdlets = @("Get-SCVirtualDiskDrive", "Get-SCVirtualHardDisk", "Get-SCVMMServer", "Get-SCVirtualMachine")
        $Cred = Get-RemoteCredentials -SSS
        Import-Module virtualmachinemanager -Cmdlet $Cmdlets -DisableNameChecking -Force | Out-Null
        $SCVMMServer = Get-SCVMMServer -ConnectAs Administrator -ComputerName $Server -Credential $Cred
        
    }
    Process {
        $VM = Get-SCVirtualMachine -VMMServer $SCVMMServer -ID $VMID
        $VMVHDs = Get-SCVirtualHardDisk -VMMServer $SCVMMServer -VM $VM
        $VHDlist  = @()
        foreach ($i in $VMVHDs) {
            $DiskID = Get-SCVirtualDiskDrive -VMMServer $SCVMMServer -VM $VM | where{$_.VirtualHardDiskId -eq $i.ID.Guid}
            $VHDlist += 
                [pscustomobject]@{
                    Name = $i.Name
                    VHDID   = $DiskID.ID.guid
                    Size = $i.MaximumSize / 1024 /1024 / 1024
                }
        }
    return $VHDlist | sort Name | select Name, VHDID, Size
 
    }
}
