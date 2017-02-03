function Get-TenantAcceptedDomain {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [switch]$Primary
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        
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