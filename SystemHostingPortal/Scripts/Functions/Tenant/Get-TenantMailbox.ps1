function Get-TenantMailbox {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Will return only a single mailbox, or write an error if more than one item matched the name.
        [switch]$Single
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Get-Mailbox") -Global
    }
    Process {
        $params = @{
            ErrorAction = "Stop"
        }

        if ($Single) {
            if (-not $Name -or $Name.IndexOf('*') -gt 0) {
                Write-Error "The name must not contain a wildcard (*) or be empty when using the -Single switch."
            }
        }

        if ($Name) {
            $result = @(Get-Mailbox -filter "UserPrincipalName -eq '$Name'")
        }
        else {
            $result = @(Get-Mailbox @params)
        }
        
        if ($Single) {
            if ($result.Count -gt 1) {
                Write-Error "More than one mailbox matched the name."
            }
            elseif ($result.Count -eq 1) {
                return $result[0]
            }
            else {
                return $null
            }
        }
        else {
            return $result
        }
        Get-PSSession | Remove-PSSession -Confirm:$false
    }

    End {
    }
}