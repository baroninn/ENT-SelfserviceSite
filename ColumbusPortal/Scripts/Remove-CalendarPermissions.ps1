
param(
    [string]$Organization,
    [string]$UserPrincipalName,
    [string[]]$User
)

    Import-Module (Join-Path $PSScriptRoot "Functions")
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2
    
    Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Get-Mailbox","Remove-MailboxFolderPermission","Get-MailboxFolderStatistics")

try {
    $mbx = Get-TenantMailbox -Organization $Organization -Name $UserPrincipalName -Single

    try {
        $statistics = $mbx | Get-MailboxFolderStatistics -FolderScope Calendar | Select-Object -First 1
        $calendarname = $statistics.Name
        $calendar = "$($mbx.UserPrincipalName):\$calendarname"

    } catch { throw "Unable to get calendar for $UserPrincipalName`: $_" }

    $SetErrors = @()
    foreach ($i in $User) {
        try {

            Remove-MailboxFolderPermission -Identity $calendar -User $i -Confirm:$false
        } 
        catch { $SetErrors += @("Unable to remove calendar permissions on mailbox $UserPrincipalName for user $($i)`: $_") }
        finally {
            if($SetErrors.Count -ne 0) {
                throw ($SetErrors -join '; ')
            }
        }
    }

} catch {
    throw $_
}