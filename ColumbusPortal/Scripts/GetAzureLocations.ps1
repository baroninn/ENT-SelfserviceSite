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

$Location = Invoke-RestMethod -Uri "$Endpoint/$($SubscriptionID)/locations?api-version=2016-06-01" -Method GET -Headers $Header -UseBasicParsing
return $Location.value | sort name