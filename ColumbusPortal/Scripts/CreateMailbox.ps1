[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [parameter(Mandatory)]
    [string]$Displayname,

    [Parameter(Mandatory)]
    [string]$UserName,
    
    [Parameter(Mandatory)]
    [string]$Password,

    [Parameter(Mandatory)]
    [string]$DomainName,

    [Parameter(Mandatory)]
    [string]$Type,

    [string[]]$EmailAddresses

)

if ($Password -like "*null*") {
    throw "password empty"
}

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Config = Get-SQLEntConfig -Organization $Organization

if ($config.ExchangeServer -eq $null -and $Config.TenantID -eq $null) {

    Throw "$Organization doesn't appear to have any mail service running.. Please check config if this is wrong.."
}
else {

    $newUserParams = @{
        Organization       = $Organization
        DisplayName        = $DisplayName
        PrimarySmtpAddress = ($UserName + '@' + $DomainName)
        Type               = $Type
        EmailAddresses     = $EmailAddresses
    }


    New-TenantMailbox @newUserParams -Verbose:$VerbosePreference

    if ($config.ExchangeServer -eq "null") {

        New-TenantUser -Organization $Organization -DisplayName $Displayname -Password $Password -PrimarySmtpAddress ($UserName + '@' + $DomainName) -SharedMailbox
    }
}