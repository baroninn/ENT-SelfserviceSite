function Get-VMServerList {
    [Cmdletbinding()]
    param (

        [bool]$Level25
    )
    Begin {

        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2
        $Cmdlets = @("Get-SCVirtualMachine", "Get-SCCloud", "Get-SCVMMServer")
        $Server= 'vmm-a.corp.systemhosting.dk'
        $Cred = Get-RemoteCredentials -SSS
        Import-Module virtualmachinemanager -Cmdlet $Cmdlets -DisableNameChecking -Force | Out-Null
        $SCVMMServer = Get-SCVMMServer -ConnectAs Administrator -ComputerName $Server -Credential $Cred
    }
    Process {
        if ($Level25 -eq $False) {
        $VMs = Get-SCVirtualMachine -VMMServer $SCVMMServer  | select Name, ID, DynamicMemoryMaximumMB, CPUCount, Memory, DynamicMemoryEnabled
        }
        else{
        $Clouds = Get-SCCloud -VMMServer $SCVMMServer | where{$_.Name -notlike "IaaS" -and 
                                                $_.Name -notlike "CORP" -and
                                                $_.Name -notlike "Nav2Go" -and
                                                $_.Name -notlike "InterXion" -and
                                                $_.Name -notlike "CPO*" -and
                                                $_.Name -notlike "BackBone"} 


            $VMs = @()
            foreach ($Cloud in $Clouds) {
            $VMs += Get-SCVirtualMachine -VMMServer $SCVMMServer -Cloud $Cloud | select Name, ID, DynamicMemoryMaximumMB, CPUCount, Memory, DynamicMemoryEnabled
            }
        }
        $Serverlist  = @()
        foreach ($vm in $VMs) {
            $Serverlist += 
                [pscustomobject]@{
                    Name                   = $vm.Name
                    VMID                   = $vm.ID.guid
                    DynamicMemoryMaximumMB = $vm.DynamicMemoryMaximumMB
                    CPUCount               = $vm.CPUCount
                    Memory                 = $vm.Memory
                    DynamicMemoryEnabled   = $vm.DynamicMemoryEnabled
                }
        }
    return $serverlist | sort Name | select Name, VMID, DynamicMemoryMaximumMB, CPUCount, Memory, DynamicMemoryEnabled
 
    }
}
