
param(
    [string]$Organization,
    [string]$UserPrincipalName,
    [string[]]$User
)

    Import-Module (Join-Path $PSScriptRoot "Functions")
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2
    $User | Out-File C:\test.txt -Append -Force
    if ($User -like "") {Write-Error "No user selected"}
    
    Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Get-Mailbox","Remove-MailboxFolderPermission","Get-MailboxFolderStatistics")
    #$Cred  = Get-RemoteCredentials -Organization $Organization
    #$Config = Get-EntConfig -Organization $Organization -JSON

try {
    $mbx = Get-TenantMailbox -Organization $Organization -Name $UserPrincipalName -Single

    try {
        $statistics = $mbx | Get-MailboxFolderStatistics -FolderScope Calendar | Select-Object -First 1
        $calendarname = $statistics.Name
        $calendar = "$($mbx.UserPrincipalName):\$calendarname"
        $calendar | Out-File C:\test.txt -Append -Force
    } catch { throw "Unable to get calendar for $UserPrincipalName`: $_" }

    $SetErrors = @()
    foreach ($i in $User) {
        try {
            "$i some user" | Out-File C:\test.txt -Append -Force
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