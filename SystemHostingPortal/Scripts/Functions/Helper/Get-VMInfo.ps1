function Get-VMInfo {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [string]$VMID
    )
    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2
        $Server= 'vmm-a.corp.systemhosting.dk'
        
    }
    Process {
        $ScriptBlock = {
            param($VMID)
            $Server= 'vmm-a.corp.systemhosting.dk'
            Import-Module virtualmachinemanager
            $VM = Get-SCVirtualMachine -VMMServer $server -ID $VMID
            $VMINFO  = @()

            if ($VM.DynamicMemoryEnabled -eq "True") {
                $VMINFO += 
                    [pscustomobject]@{
                        Name                   = $VM.Name
                        ID                     = $VM.ID.guid
                        Memory                 = $vm.DynamicMemoryMaximumMB
                        CPUCount               = $vm.CPUCount
                        DynamicMemoryEnabled   = $vm.DynamicMemoryEnabled
                    }
            }
            else{
                $VMINFO += 
                    [pscustomobject]@{
                        Name                   = $VM.Name
                        ID                     = $VM.ID.guid
                        Memory                 = $vm.Memory
                        CPUCount               = $vm.CPUCount
                        DynamicMemoryEnabled   = $vm.DynamicMemoryEnabled
                    }
            }

        return $VMINFO

        }
        $VM = Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock -ArgumentList $VMID

        return $VM | sort Name | select Name, ID, DynamicMemoryMaximumMB, CPUCount, Memory, DynamicMemoryEnabled


 
    }
}
