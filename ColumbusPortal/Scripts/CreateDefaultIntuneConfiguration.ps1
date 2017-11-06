[Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Organization
    )

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization -GraphAPI

Create-DefaultIntuneDeviceConfigurations -Header $Header
Create-DefaultIntuneComplianceSettings -Header $Header
Create-DefaultIntuneDeviceGroups -Header $Header
Start-Sleep 5
Assign-DefaultIntuneDeviceGroups -Header $Header