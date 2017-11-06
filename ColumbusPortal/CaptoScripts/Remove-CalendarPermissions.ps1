[Cmdletbinding()]
param(
    [string]$Organization,
    [string]$UserPrincipalName,
    [string[]]$User
)

    Import-Module (Join-Path $PSScriptRoot Capto)
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2

    Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox","Remove-MailboxFolderPermission","Get-MailboxFolderStatistics")

try {
    $mbx = Get-TenantMailbox -TenantName $Organization -Name $UserPrincipalName -Single

    try {
        $statistics = $mbx | Get-MailboxFolderStatistics -FolderScope Calendar | Select-Object -First 1
        $calendarname = $statistics.Name
        $calendar = "$($mbx.UserPrincipalName):\$calendarname"
    } catch { throw "Unable to get calendar for $UserPrincipalName`: $_" }

    $SetErrors = @()
    for($i = 0; $i -lt $User.Count; $i++) {
        try {

            Remove-MailboxFolderPermission -Identity $calendar -User $User[$i] -Confirm:$false
        } 
        catch { $SetErrors += @("Unable to remove calendar permissions on mailbox $UserPrincipalName for user $($User[$i])`: $_") }
        finally {
            if($SetErrors.Count -ne 0) {
                throw ($SetErrors -join '; ')
            }
        }
    }

} catch {
    throw $_
}