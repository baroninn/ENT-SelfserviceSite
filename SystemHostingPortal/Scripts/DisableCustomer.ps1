[Cmdletbinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$Organization,

    [switch]$Confirm
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

    if (-not $Confirm) { throw "You haven't confirmed to disable the customer.. Are you really sure you wanna do this?!?" }

    Import-Module (Join-Path $PSScriptRoot Capto)

    $Config = Get-TenantConfig -TenantName $Organization -ErrorAction SilentlyContinue

    $Disabled = Get-ADOrganizationalUnit -Server hosting.capto.dk $Config.OUs.path[1] -Properties Description
    if($Disabled.Description -ne $null){
                throw ($Organization + " was disabled on " + $Disabled.Description + ". There is " + (New-TimeSpan -Start ([Datetime]::Today.AddDays(-28)) -End $Disabled.Description).Days + " days left before removing is possible..")
                }

    Import-Module (New-ExchangeProxyModule -Command "Set-CASMailbox") -DisableNameChecking

    $Config = Get-TenantConfig -TenantName $Organization -ErrorAction SilentlyContinue

    Set-ADOrganizationalUnit $Config.OUs.path[1] -Add @{Description=[Datetime]::Today.ToShortDateString()} -Server hosting.capto.dk

    $mbx = @(Get-TenantMailbox -TenantName $Organization)
    if ($mbx.Count -eq 0) {
        Write-Error "No mailbox was found for Organization '$Organization'."
    }
    else{
        foreach($i in $mbx){
            if($i.CustomAttribute12 -ne 'Disabled' -and $i.RecipientTypeDetails -eq 'UserMailbox'){
	            Disable-ADAccount -Identity $i.DistinguishedName -Server $Config.DomainFQDN
                Set-CASMailbox -Identity $i.DistinguishedName -ActiveSyncEnabled $false
            }
        }
}