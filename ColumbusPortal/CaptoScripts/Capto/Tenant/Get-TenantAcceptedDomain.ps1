function Get-TenantAcceptedDomain {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, 
                   ValueFromPipelineByPropertyName, 
                   ParameterSetName="DomainName")]
        [string]$DomainName,

        [Parameter(Mandatory, 
                   ValueFromPipeline, 
                   ValueFromPipelineByPropertyName, 
                   ParameterSetName="TenantName")]
        [string]$TenantName,

        [Parameter(ParameterSetName="TenantName")]
        [switch]$Primary
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        Import-Module (New-ExchangeProxyModule -Command "Get-AcceptedDomain")
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            'TenantName' {
                $domain = @()
                $domain += Get-AcceptedDomain -Identity $TenantName -ErrorAction SilentlyContinue
                if (-not $Primary) {
                    $domain += Get-AcceptedDomain -Identity "$TenantName -*" -ErrorAction SilentlyContinue
                }
                $domain
            }
            'DomainName' {
                @(Get-AcceptedDomain | where {$_.DomainName -eq $DomainName})
            }
        }
    }
}