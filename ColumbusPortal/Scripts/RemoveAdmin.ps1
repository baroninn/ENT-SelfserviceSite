[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $SamAccountName
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

Remove-AdminUser -SamAccountName $SamAccountName -Verbose:$VerbosePreference