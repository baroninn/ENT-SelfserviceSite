[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$VMID,

    [Parameter(Mandatory)]
    [string]$DateTime,

    [Parameter(Mandatory)]
    [string]$TaskID,

    [Parameter(Mandatory)]
    [string]$Email
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

$Cmdlets = @("Get-SCVMMServer", "Get-SCVirtualMachine")

Import-Module (Join-Path $PSScriptRoot Functions)
$Server= 'vmm-a.corp.systemhosting.dk'
$Cred = Get-RemoteCredentials -SSS
Import-Module virtualmachinemanager -Cmdlet $Cmdlets -DisableNameChecking -Force | Out-Null
$SCVMMServer = Get-SCVMMServer -ConnectAs Administrator -ComputerName $Server -Credential $Cred


## Convert VMID back to name
$VMName = Get-SCVirtualMachine -VMMServer $SCVMMServer -ID $VMID | select -ExpandProperty name

$runbookIds = @{
    ScheduleReboot   = 0;
}

$runbookIds.ScheduleReboot   = 'aff2a4e4-ba95-4b1c-9008-36dbb4380b3d'

$parameters = @{
    "VMName"     = "$VMName"
}

Import-Module (Join-Path $PSScriptRoot OrchestratorHook2.dll)
$RunbookId = $runbookIds.ScheduleReboot

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

try {
    StartRunbook -EmailStatusTo $Email -Parameters $paramString -ScheduledTime $ScheduledTime -RunbookId $RunbookId -TaskID $TaskID | Out-Null
    Write-Output "$VMName has been scheduled for reboot on $DateTime"
}
catch {
    throw $_
}
Remove-Module OrchestratorHook2 -Force

