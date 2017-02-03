[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Mail,
    [string]$Organization,
    [bool]$GetALL
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

if ( $mail -notlike "*@systemhosting.dk" ) { throw "Error, you can only send the report to systemhosting employes" }

if ($GetALL -ne $false) {
Get-ItemsReport -Organization $Organization -Mail $Mail -GetALL
}
else{
    Get-ItemsReport -Organization $Organization -Mail $Mail
    }