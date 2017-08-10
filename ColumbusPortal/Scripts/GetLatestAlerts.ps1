[Cmdletbinding()]
param (
    [switch]$Freespace,
    [switch]$LatestAlerts,
    [switch]$PendingReboots
    )

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions") -DisableNameChecking | Out-Null

<#
$Cred = Get-RemoteCredentials -SSS
$SCOMServer = 'sht015.corp.systemhosting.dk'
Import-Module OperationsManager -Force -DisableNameChecking | Out-Null

#$LatestAlerts = Get-SCOMAlert -ResolutionState 0 -Severity 2 -Credential $Cred -ComputerName $SCOMServer | sort TimeRaised -Descending | select PrincipalName, Name, Severity, TimeRaised, Description -First 20

$Group = Get-SCOMGroup -Id "d0760249-5bc7-9897-aa33-b35887c0ec08" -Credential $Cred -ComputerName $SCOMServer
#$Group = Get-SCOMGroup -DisplayName "Systemhosting.Backbone.HealthWatcher" -Credential $Cred -ComputerName $SCOMServer
#$instance = $Group.GetRelatedMonitoringObjects('Recursive')
#$LatestAlerts = Get-SCOMAlert -Instance $instance -Credential $Cred -ComputerName $SCOMServer
$LatestAlerts = $Group.GetMonitoringAlerts([Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive) | sort TimeRaised -Descending | select PrincipalName, Name, Severity, TimeRaised, Description -First 20
#>

if ($Freespace) {
    Get-ScomAlerts -Freespace
}
if ($LatestAlerts) {
    Get-ScomAlerts -LatestAlerts
}
if ($PendingReboots) {
    Get-ScomAlerts -PendingReboot
}