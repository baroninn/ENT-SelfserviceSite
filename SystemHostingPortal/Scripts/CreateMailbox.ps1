[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $Name,

    [Parameter(Mandatory)]
    [string]
    $PrimarySmtpAddress,

    [Parameter(Mandatory)]
    [ValidateSet("SharedMailbox","RoomMailbox")]
    [string]
    $Type,

    [string[]]
    $EmailAddresses
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

$params = @{
    TenantName = $Organization
    Name = $Name
    PrimarySmtpAddress = $PrimarySmtpAddress
    Type = $Type
}

if ($EmailAddresses) {
    $params.Add("EmailAlias", $EmailAddresses)
}

New-TenantMailbox @params