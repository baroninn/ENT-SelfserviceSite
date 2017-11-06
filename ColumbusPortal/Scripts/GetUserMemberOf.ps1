[CmdletBinding()]
param(
    [string]$Organization,
    [string]$UserPrincipalName
)

$ErrorActionPreference = 'stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

Get-UserMemberOf -Organization $Organization -UserPrincipalName $UserPrincipalName