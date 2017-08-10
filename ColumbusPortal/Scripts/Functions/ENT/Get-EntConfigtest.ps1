function Get-EntConfigtest {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

    }
    Process {

    $ID = [pscustomobject]@{
          Organization = $Organization
          DomainFQDN   = 'testFQDN'
          Domain       = 'Corptest'
          }

    return $ID

    }
}