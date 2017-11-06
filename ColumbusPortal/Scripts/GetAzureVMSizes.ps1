[Cmdletbinding()]
param (
    [string]$Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization
$SubscriptionID = Get-AzureAPISubID -Header $Header
$Endpoint = "https://management.azure.com/subscriptions"

$Sizes = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/providers/Microsoft.Compute/locations/westeurope/vmSizes?api-version=2017-03-30" -Method GET -Headers $Header -UseBasicParsing
return $Sizes.value | sort name