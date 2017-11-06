[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$VMID,

    [Parameter(Mandatory)]
    [string]$DateTime,

    [Parameter(Mandatory)]
    [string]$CPU,

    [Parameter(Mandatory)]
    [string]$RAM,

    [Parameter(Mandatory)]
    [string]$Email,

    [Parameter(Mandatory)]
    [string]$TaskID,

    [string]$DynamicMemoryEnabled
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot OrchestratorHook2.dll)
Import-Module (Join-Path $PSScriptRoot Functions)

$Cmdlets = @("Get-SCVMMServer", "Get-SCVirtualMachine")

$Server= 'vmm-a.corp.systemhosting.dk'
$Cred = Get-RemoteCredentials -SSS
Import-Module virtualmachinemanager -Cmdlet $Cmdlets -DisableNameChecking -Force > $null
$SCVMMServer = Get-SCVMMServer -ConnectAs Administrator -ComputerName $Server -Credential $Cred

## Convert VMID back to name

$VM = Get-SCVirtualMachine -VMMServer $SCVMMServer -ID $VMID


$runbookIds = @{
    ChangeVMCPU = 0;
}

$runbookIds.ChangeVMCPU = 'ebdc76b6-c29e-4865-ae19-ae8f2661d85e'

[int]$CPU = $CPU
[int]$RAM = $RAM

$parameters = @{
    "CPUCount" = $CPU
    "RAM"      = $RAM * 1024
    "VMName"   = "$($VM.Name)"
}

if (-not $DynamicMemoryEnabled -eq '') {
    if ($vm.DynamicMemoryEnabled -eq $false -and $DynamicMemoryEnabled -eq 'True') {
        $parameters.Add("DynamicMemoryEnabled", "true")
    }
    if ($vm.DynamicMemoryEnabled -eq $true -and $DynamicMemoryEnabled -eq 'false') {
        $parameters.Add("DynamicMemoryEnabled", "false")
    }
    if ($vm.DynamicMemoryEnabled -eq $false -and $DynamicMemoryEnabled -eq 'false') {
        $parameters.Add("DynamicMemoryEnabled", "false")
    }
    if ($vm.DynamicMemoryEnabled -eq $true -and $DynamicMemoryEnabled -eq 'true') {
        $parameters.Add("DynamicMemoryEnabled", "true")
    }
}
else {
    $parameters.Add("DynamicMemoryEnabled", "$($vm.DynamicMemoryEnabled)")
}



$RunbookId = $runbookIds.ChangeVMCPU

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