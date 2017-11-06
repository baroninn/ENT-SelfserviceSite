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
        $Cred = Get-RemoteCredentials -SSS
        $Cmdlets = @("Get-SCVMMServer", "Get-SCVirtualMachine")
        Import-Module virtualmachinemanager -Cmdlet $Cmdlets -DisableNameChecking -Force > $null
        $SCVMMServer = Get-SCVMMServer -ConnectAs Administrator -ComputerName $Server -Credential $Cred
    }
    Process {
        $VM = Get-SCVirtualMachine -VMMServer $SCVMMServer -ID $VMID
        $VMINFO  = @()

        if ($VM.DynamicMemoryEnabled -eq "True") {
            $VMINFO += 
                [pscustomobject]@{
                    Name                   = $VM.Name
                    ID                     = $VM.ID.guid
                    Memory                 = $vm.DynamicMemoryMaximumMB / 1024
                    CPUCount               = $vm.CPUCount
                    DynamicMemoryEnabled   = $vm.DynamicMemoryEnabled
                }
        }
        else{
            $VMINFO += 
                [pscustomobject]@{
                    Name                   = $VM.Name
                    ID                     = $VM.ID.guid
                    Memory                 = $vm.Memory / 1024
                    CPUCount               = $vm.CPUCount
                    DynamicMemoryEnabled   = $vm.DynamicMemoryEnabled
                }
        }

    return $VMINFO | sort Name | select Name, ID, DynamicMemoryMaximumMB, CPUCount, Memory, DynamicMemoryEnabled
 
    }
}
