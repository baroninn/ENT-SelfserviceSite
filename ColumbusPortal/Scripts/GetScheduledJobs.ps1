[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$job
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

if ($job -eq 'reboot') {
    Get-ScheduledJobs -reboot
}
if ($job -eq 'expandvhd') {
    Get-ScheduledJobs -expandvhd
}
if ($job -eq 'expandcpuram') {
    Get-ScheduledJobs -expandcpuram
}