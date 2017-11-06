[Cmdletbinding()]
param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [string]$Organization,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string]$UserPrincipalName,

    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$StartTime,

    [Parameter(ValueFromPipelineByPropertyName)]
    [string]$EndTime,

    [String]$Internal,
    [String]$External
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

Import-Module (Join-Path $PSScriptRoot Functions)

$params = @{
    Organization         = $Organization
    UserPrincipalName    = $UserPrincipalName
}
if ($StartTime) {
    $params.Add("StartTime", $StartTime)
}
if ($EndTime) {
    $params.Add("EndTime", $EndTime)
}
if ($Internal) {
    $params.Add("Internal", $Internal)
}
if ($External) {
    $params.Add("External", $External)
}

Set-MailboxOOFMessage @params