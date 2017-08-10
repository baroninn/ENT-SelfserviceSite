[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $SamAccountName,

    [Parameter(Mandatory)]
    [string]
    $Password

)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

Reset-AdminUserPassword -SamAccountName $SamAccountName -Password $Password -Verbose:$VerbosePreference