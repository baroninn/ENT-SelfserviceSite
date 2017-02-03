function Get-TenantGPLink {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Domain = $env:USERDNSDOMAIN
    )

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2

    [xml]$xml = Get-GPOReport -Name $Name -ReportType Xml -Domain $Domain

    $xml.GPO.LinksTo.SOMPath.Replace('hosting.capto.dk/SYSTEMHOSTING/Customer/', '').Replace('/Users', '')
}