[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $UserPrincipalName,

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

    [string[]]$EmailAlias,

    [bool]$PasswordNeverExpires,
        
    [bool]$TestUser,

    [bool]$StudJur,

    [bool]$MailOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

$newUserParams = @{
    TenantName         = $Organization
    PrimarySmtpAddress = ($UserPrincipalName + '@' + $DomainName)
    FirstName          = $FirstName 
    LastName           = $LastName 
    Password           = $Password
}

if ($EmailAlias) {
    $newUserParams.Add("EmailAlias", $EmailAlias)
}
if ($PasswordNeverExpires) {
    $newUserParams.Add("PasswordNeverExpires", $true)
}
if ($TestUser) {
    $newUserParams.Add("TestUser", $true)
}
if ($StudJur) {
    $newUserParams.Add("StudJur", $true)
}
if ($MailOnly) {
    $newUserParams.Add("MailOnly", $true)
}

New-TenantUser @newUserParams -Verbose:$VerbosePreference