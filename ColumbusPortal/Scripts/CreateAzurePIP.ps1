[Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        $Organization,

        [Parameter(Mandatory=$true)]
        $Name,
        
        [Parameter(Mandatory=$true)]
        $RessourceGroupname,

        [Parameter(Mandatory=$true)]
        $AllocationMethod,

        [Parameter(Mandatory=$true)]
        $Version,

        [Parameter(Mandatory=$true)]
        $Location
    )

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization

New-AzureAPIPublicIP -Header $Header -Name $Name -RessourceGroupname $RessourceGroupname -AllocationMethod $AllocationMethod -Version $Version -Location $Location