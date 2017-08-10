[cmdletbinding()]
param(
    [parameter(mandatory)]
    [string]$Organization,
    [parameter(mandatory)]
    [string]$ID,
    [parameter(mandatory)]
    [string]$FirstName,
    [parameter(mandatory)]
    [string]$LastName,
    [parameter(mandatory)]
    [string]$SamAccountName,
    [parameter(mandatory)]
    [string]$Password,
    [parameter(mandatory)]
    [string]$Company,
    [parameter(mandatory)]
    [string]$Email,
    [parameter(mandatory)]
    [string]$Description,
    [parameter(mandatory)]
    [string]$Expiredate
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

New-EXTAdminUser -Organization $Organization -ID $ID -FirstName $FirstName -LastName $LastName -SamAccountName $SamAccountName -Password $Password -Company $Company -Email $Email -Expiredate $Expiredate -Description $Description