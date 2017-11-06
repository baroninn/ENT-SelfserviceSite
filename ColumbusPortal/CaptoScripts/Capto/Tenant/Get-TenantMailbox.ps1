function Get-TenantMailbox {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        # Will return only a single mailbox, or write an error if more than one item matched the name.
        [switch]$Single
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox")
    }
    Process {
        $params = @{
            Filter      = "CustomAttribute1 -eq '$TenantName'"
            ErrorAction = "Stop"
        }

        if ($Name) {
            $params.Add("Identity", $Name)
        }

        if ($Single) {
            if (-not $Name -or $Name.IndexOf('*') -gt 0) {
                Write-Error "The name must not contain a wildcard (*) or be empty when using the -Single switch."
            }
        }

        $result = @(Get-Mailbox @params)
        foreach ($mbx in $result) {
            if ($mbx.CustomAttribute10 -ne "") {
                try {
                    $mbx | Add-Member -NotePropertyName ShtProperties -NotePropertyValue (ConvertFrom-Json -InputObject $mbx.CustomAttribute10)
                }
                catch {
                    Write-Error "Error parsing ShtProperties on $($mbx.DisplayName)"
                }
            }
            else {
                $mbx | Add-Member -NotePropertyName ShtProperties -NotePropertyValue ([pscustomobject]@{})
                Write-Warning "ShtProperties was not found on $($mbx.DisplayName)"
            }
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
    }
    End {
    }
}