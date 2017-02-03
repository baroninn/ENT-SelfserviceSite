[Cmdletbinding()]
param(
    [string]$Organization,
    
    [string]$SendAsGroup,

    [string]$Alias,

    [bool]$Force,

    [bool]$Remove,

    [bool]$UpdateALL
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

if ($Force) {
    Enable-Sikkermail -TenantName $Organization -SendAsGroup $SendAsGroup -Alias $Alias -Force
}
if ($Remove -and -not $Force) { 
    Enable-Sikkermail -TenantName $Organization -SendAsGroup $SendAsGroup -Alias $Alias -Remove
}
if (-Not $Remove -and -not $Force -and $UpdateALL) {
    Enable-Sikkermail -TenantName 'CPO' -UpdateALL ## Not pretty , but SSS returns a null string so default parameters cannot be used..
}
if (-Not $Remove -and -not $Force -and -not $UpdateALL) {
    Enable-Sikkermail -TenantName $Organization -SendAsGroup $SendAsGroup -Alias $Alias
}