[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Header = Get-AzureAPIToken -Organization 098 -GraphAPI

$Policys = Get-AzureIntuneComplianceSetting -Header $Header

foreach ($Policy in $Policys) {
    $i = Get-AzureIntuneComplianceOverview -Header $Header -ID $Policy.id

    $OverviewObject = [pscustomobject]@{
        Organization       = $Organization
        name               = $Policy.displayName
        id                 = $Policy.id
        pendingCount       = $i.pendingCount
        notApplicableCount = $i.notApplicableCount
        successCount       = $i.successCount
        errorCount         = $i.errorCount
        failedCount        = $i.failedCount
        lastUpdateDateTime = $i.lastUpdateDateTime
    }

    $OverviewObject
}