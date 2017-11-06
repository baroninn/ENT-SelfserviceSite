param(
    [Parameter(Mandatory=$true)]
    $Organization,
    
    [Parameter(Mandatory=$true)]
    $UserPrincipalName,
    
    [Switch]
    $FullAccess,
    
    [Switch]
    $SendAs
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

if(!$FullAccess -and !$SendAs) { 
  throw "No group type selected"
}

$Config = Get-TenantConfig -TenantName $Organization

if ($FullAccess) {
    New-TenantMailboxPermissionGroup -TenantName $Config.Name -UserPrincipalName $UserPrincipalName -Name "$($Organization)_Mailbox_$($UserPrincipalName.ToLower())_FullAccess" -Permission FullAccess -Path $Config.MailboxGroupsOU
}

if ($SendAs) { 
    New-TenantMailboxPermissionGroup -TenantName $Config.Name -UserPrincipalName $UserPrincipalName -Name "$($Organization)_Mailbox_$($UserPrincipalName.ToLower())_SendAs" -Permission SendAs -Path $Config.MailboxGroupsOU
}
