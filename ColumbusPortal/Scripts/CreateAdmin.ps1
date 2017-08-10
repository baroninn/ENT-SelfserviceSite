[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $SamAccountName,

    [Parameter(Mandatory)]
    [string]
    $FirstName,

    [Parameter(Mandatory)]
    [string]
    $LastName,

    [Parameter(Mandatory)]
    [string]
    $Password,

    [Parameter(Mandatory)]
    [string]
    $DisplayName,

    [Parameter(Mandatory)]
    [string]
    $Department

)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$newAdminParams = @{
    DisplayName        = $DisplayName
    SamAccountName     = $SamAccountName
    FirstName          = $FirstName 
    LastName           = $LastName 
    Password           = $Password
    Department         = $Department
}

New-AdminUser @newAdminParams -Verbose:$VerbosePreference