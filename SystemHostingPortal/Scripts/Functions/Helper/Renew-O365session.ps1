function Renew-O365session {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)]
        [string]
        $Organization
    )

    $currentModule  = Get-Module -Name "tmp*"
    $currentSession = Get-PSSession -Name "EntExchange"
    $Commands = $currentModule.ExportedCommands.Keys

    Remove-Module $currentModule
    Remove-PSSession $currentSession

    Start-Sleep 15
    Import-Module (New-ExchangeProxyModule -Organization $Organization -Command $Commands)
    Get-PSSession -Name "EntExchange"
}