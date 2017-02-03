[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

$mbxs = @(Get-TenantMailbox -TenantName $Organization)
$excluded = 0

foreach ($mbx in $mbxs) {
    try {
        if ($mbx.ShtProperties.ExcludeFromMailboxAutoResize) {
            $excluded++
        }
    }
    catch {
    }
}

$result = [pscustomobject]@{
    Response = "Unknown error"
}

if ($excluded -eq 0) {
    $result.Response = "Auto resizing is enabled"
}
elseif ($excluded -eq $mbxs.Count) {
    $result.Response = "Excluded from auto resizing"
}
else {
    $result.Response = "Inconsistent configuration"
}

ConvertTo-Json -InputObject $result -Compress