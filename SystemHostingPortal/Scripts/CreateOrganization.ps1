[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $EmailDomainName,

    [Parameter(Mandatory)]
    [ValidateSet("AdvoPlus", "Legal", "Member2015")]
    $Solution,

    [Parameter(Mandatory)]
    [string]
    $FileServer,
    
    [Parameter(Mandatory)]
    [string]
    $FileServerDriveLetter
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

if ($FileServerDriveLetter.Length -eq 1 -and $FileServerDriveLetter -match '^[a-zA-Z]') {
    $FileServerDriveLetter = $FileServerDriveLetter.ToUpper()
}
elseif ($FileServerDriveLetter.Length -ge 2 -and $FileServerDriveLetter.Length -le 3 -and $FileServerDriveLetter -match '^[a-zA-Z][^a-zA-Z]{1,2}') {
    $FileServerDriveLetter = $FileServerDriveLetter[0].ToString().ToUpper()
}
else {
    throw "File Server Drive Letter must be a single character, for example 'E'."
}

Import-Module (Join-Path $PSScriptRoot "Capto")

New-Tenant -Name $Organization -PrimarySmtpAddress $EmailDomainName -Product $Solution -FileServer $FileServer -FileServerDriveLetter $FileServerDriveLetter
