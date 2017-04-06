[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$DateTime,

    [Parameter(Mandatory)]
    [string]$CPU,

    [Parameter(Mandatory)]
    [string]$RAM,

    [Parameter(Mandatory)]
    [string]$Email
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot OrchestratorHook2.dll)
Import-Module (Join-Path $PSScriptRoot Functions)
$VMMServer= 'vmm-a.corp.systemhosting.dk'

## Convert VMID back to name
$ScriptBlock = {
    param($Name)

    Import-Module VirtualMachineManager
    $VMMServer= 'vmm-a.corp.systemhosting.dk'

    $VMName = Get-SCVirtualMachine -VMMServer $VMMServer -ID $Name

    return $VMName
}

$VM = Invoke-Command -ComputerName $VMMServer -ScriptBlock $ScriptBlock -ArgumentList $Name
$Name = $VM.Name



$runbookIds = @{
    ChangeVMCPU = 0;
}

$runbookIds.ChangeVMCPU = 'ebdc76b6-c29e-4865-ae19-ae8f2661d85e'

[int]$CPU = $CPU
[int]$RAM = $RAM

$parameters = @{
    "CPUCount" = $CPU
    "RAM"      = $RAM * 1024
    "VMName"   = "$Name"
}


$RunbookId = $runbookIds.ChangeVMCPU

[datetime]$ConvertTime = "$DateTime"
$ScheduledTime = $ConvertTime.ToString("yyyy-MM-dd HH:mm:ss")

$paramString = ""

foreach ($param in $parameters.Keys) {
    $paramString += "$($param)|1$($parameters[$param])|2"
}

$paramString = $paramString.Substring(0, $paramString.Length-2)


function StartRunbook($EmailStatusTo, $Parameters, $ScheduledTime, $RunbookId) {
    $params = [string]::Format("EmailStatusTo={0}&Parameters={1}&ScheduledTime={2}&RunbookId={3}&Status=Scheduled", $EmailStatusTo, $Parameters, $ScheduledTime, $RunbookId)
    $params 

    $hook = New-Object OrchestratorHook2.OrchestratorHook
    $hook.Connect()
    $hook.Run("80f0fe85-c2f6-4603-a1c7-5c96ac12f5cb", $params)
}

StartRunbook -EmailStatusTo $Email -Parameters $paramString -ScheduledTime $ScheduledTime -RunbookId $RunbookId | Out-Null

Remove-Module OrchestratorHook2 -Force