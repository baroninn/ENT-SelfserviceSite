function Get-TenantMailContact {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $TenantName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [switch]
        $Single
    )

    Begin {
        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2

        Import-Module (New-ExchangeProxyModule -Command "Get-MailContact")
    }

    Process {
        $params = @{
            Filter      = "CustomAttribute1 -eq '$TenantName'"
            ErrorAction = "Stop"
        }

        if ($Name) {
            $params.Add("Identity", $name)
        }

        if ($Single) {
            if (-not $Name -or $Name.IndexOf('*') -gt 0) {
                Write-Error "The name must not contain a wildcard (*) or be empty when using the -Single switch."
            }
        }

        $mailContact = @(Get-MailContact @params)

        if ($Single) {
            if ($mailContact.Count -gt 1) {
                Write-Error "More than one mailcontact matched the name."
            }
            elseif ($mailContact.Count -eq 1) {
                return $mailContact[0]
            }
            else {
                return $null
            }
        }
        else {
            return $mailContact
        }
    }
}
