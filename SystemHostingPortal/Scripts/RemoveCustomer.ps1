[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [switch]$RemoveData,

    [switch]$Confirm

)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

if (-not $Confirm) { throw "You haven't confirmed to remove the customer.. Are you really sure you wanna do this?!?" }

Import-Module (Join-Path $PSScriptRoot "Capto")

$config = Get-TenantConfig -TenantName $Organization

<# ## disable date..
$Disabled = Get-ADOrganizationalUnit -Server hosting.capto.dk $Config.OUs.path[1] -Properties Description
if($Disabled.Description -ne $null){
    if($Disabled.Description -le [Datetime]::Today.AddDays(-28).ToShortDateString()){
        Write-Verbose "It has been more than 1 month, continuing.."}

    else{
         throw ($Organization + " was disabled on " + $Disabled.Description + ". There is " + (New-TimeSpan -Start ([Datetime]::Today.AddDays(-28)) -End $Disabled.Description).Days + " days left before removing is possible..")
        }
}
else{
     throw "$Organization has not been disabled yet.. The tenant needs to be disabled for 28 days, before you are allowed to delete"
 }
 #>

if ($RemoveData) {
    Remove-Tenant -TenantName $Organization -RemoveData
}
else{
    Remove-Tenant -TenantName $Organization
}