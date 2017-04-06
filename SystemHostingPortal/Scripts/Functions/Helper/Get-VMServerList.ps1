function Get-VMServerList {
    [Cmdletbinding()]
    param (

        [string]$Level30
    )
    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2
        $Server= 'vmm-a.corp.systemhosting.dk'
        
    }
    Process {
        $ScriptBlock = {
            $Server= 'vmm-a.corp.systemhosting.dk'
            Import-Module virtualmachinemanager
            $VMs = Get-SCVirtualMachine -VMMServer $server
            $Serverlist  = @()
            foreach ($vm in $VMs) {
                $Serverlist += 
                  [pscustomobject]@{
                      Name                   = $vm.Name
                      ID                     = $vm.ID.guid
                      DynamicMemoryMaximumMB = $vm.DynamicMemoryMaximumMB
                      CPUCount               = $vm.CPUCount
                      Memory                 = $vm.Memory
                      DynamicMemoryEnabled   = $vm.DynamicMemoryEnabled
                  }
            }
        return $serverlist

        }
        $VMS = Invoke-Command -ComputerName $Server -ScriptBlock $ScriptBlock

        return $VMS | sort Name | select Name, ID, DynamicMemoryMaximumMB, CPUCount, Memory, DynamicMemoryEnabled


 
    }
}
