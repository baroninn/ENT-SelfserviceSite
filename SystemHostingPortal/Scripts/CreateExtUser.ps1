[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $UserName,

    [Parameter(Mandatory)]
    [string]
    $DisplayName,

    [Parameter(Mandatory)]
    [string]
    $DomainName,

    [Parameter(Mandatory)]
    [string]
    $Description,

    [Parameter(Mandatory)]
    [string]
    $ExpirationDate,

    [Parameter(Mandatory)]
    [string]
    $Password

)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$newUserParams = @{
    Organization       = $Organization
    PrimarySmtpAddress = ($UserName + '@' + $DomainName)
    DisplayName        = $DisplayName 
    Description        = $Description 
    Password           = $Password
    ExpirationDate     = $ExpirationDate
}

New-TenantEXTUser @newUserParams -Verbose:$VerbosePreference