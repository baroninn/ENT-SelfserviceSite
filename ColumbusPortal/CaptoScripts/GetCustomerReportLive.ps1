[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

$Config = Get-TenantConfig -Name $Organization

if ((Get-TenantGPLink -Name $Config.GroupPolicy.AdvoPlusNative.Name -Domain $config.DomainFQDN) -contains $Organization) {
    Get-TenantBillingInformation -TenantName $Config.Name -FileServer $Config.FileServer.Fqdn -FilePath (Resolve-UncPath -Path $Config.NewCustomerDataFilePath) -NativeDatabaseServer $Config.NativeDatabaseServer.Fqdn -NativeDatabasePath $Config.NativeDatabaseServer.DatabasePath -DomainName $Config.DomainFQDN
}
else {
    Get-TenantBillingInformation -TenantName $Config.Name -FileServer $Config.FileServer.Fqdn -FilePath (Resolve-UncPath -Path $Config.NewCustomerDataFilePath) -DatabaseServer $Config.DatabaseServer.Fqdn -DomainName $Config.DomainFQDN
}