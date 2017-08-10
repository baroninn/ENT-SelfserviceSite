$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Cred = Get-RemoteCredentials -SSS
$SCOMServer = 'sht015.corp.systemhosting.dk'
Import-Module OperationsManager

$pendingreboot = Get-SCOMAlert -Name "Pending Reboot" -ResolutionState 0 -Credential $Cred -ComputerName $SCOMServer
return $Pendingreboot | sort PrincipalName

Get-Module OperationsManager | Remove-Module