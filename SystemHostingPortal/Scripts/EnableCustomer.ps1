param(
    [parameter(Mandatory=$true)]
    $Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

Import-Module (New-ExchangeProxyModule -Command "Set-CASMailbox") -DisableNameChecking

$Config = Get-TenantConfig -TenantName $Organization -ErrorAction SilentlyContinue

Set-ADOrganizationalUnit $Config.OUs.path[1] -Remove @{Description=[Datetime]::Today.ToShortDateString()} -Server hosting.capto.dk

$mbx = @(Get-TenantMailbox -TenantName $Organization)
if ($mbx.Count -eq 0) {
    Write-Error "No mailbox was found for Organization '$Organization'."
}
else{
    foreach($i in $mbx){
        if($i.CustomAttribute12 -ne 'Disabled' -and $i.RecipientTypeDetails -eq 'UserMailbox'){
	        Enable-ADAccount -Identity $i.DistinguishedName -Server $Config.DomainFQDN
            Set-CASMailbox -Identity $i.DistinguishedName -ActiveSyncEnabled $true
        }
    }
}