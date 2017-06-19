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
    $CopyFrom,

    [Parameter(Mandatory)]
    [string]
    $DomainName,

    [Parameter(Mandatory)]
    [string]
    $FirstName,

    [Parameter(Mandatory)]
    [string]
    $LastName,

    [Parameter(Mandatory)]
    [string]
    $Password,

    [bool]$PasswordNeverExpires,
        
    [bool]$TestUser

)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$newUserParams = @{
    Organization       = $Organization
    PrimarySmtpAddress = ($UserName + '@' + $DomainName)
    FirstName          = $FirstName 
    LastName           = $LastName 
    Password           = $Password
    CopyFrom           = $CopyFrom
}

if ($PasswordNeverExpires) {
    $newUserParams.Add("PasswordNeverExpires", $true)
}
if ($TestUser) {
    $newUserParams.Add("TestUser", $true)
}


New-TenantUser @newUserParams -Verbose:$VerbosePreference