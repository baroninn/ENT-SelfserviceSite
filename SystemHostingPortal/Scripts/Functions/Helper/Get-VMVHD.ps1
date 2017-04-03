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
        
    }
    Process {
        $ScriptBlock = {
            param(
                [Parameter(Mandatory)]$VMID
            )
            $Server = 'vmm-a.corp.systemhosting.dk'
            Import-Module virtualmachinemanager
            $VM = Get-SCVirtualMachine -VMMServer $Server -ID $VMID
            $VMVHDs = Get-SCVirtualHardDisk -VMMServer $Server -VM $VM
            $VHDlist  = @()
            foreach ($i in $VMVHDs) {
                $VHDlist += 
                  [pscustomobject]@{
                      Name = $i.Name
                      ID   = $i.ID.guid
                      Size = $i.MaximumSize / 1024 /1024 / 1024
                  }
            }
        return $VHDlist

        }
        $VHDs = Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock -ArgumentList $VMID

        return $VHDs | sort Name | select Name, ID, Size


 
    }
}
