param(
    [string]$Organization,
    [string]$UserPrincipalName,
    [string[]]$User,
    [string[]]$AccessRights
)

    Import-Module (Join-Path $PSScriptRoot "Functions")
    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2

    Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Get-Mailbox","Set-MailboxFolderPermission","Get-MailboxFolderStatistics","Add-MailboxFolderPermission")

try {

    $mbx = Get-TenantMailbox -Organization $Organization -Name $UserPrincipalName -Single
    if($mbx.UserPrincipalName -ne $UserPrincipalName) {
        throw "Found user $($mbx.UserPrincipalName) does not match identity $UserPrincipalName - Please try to be more specific"
    }

    try {
        $statistics = $mbx | Get-MailboxFolderStatistics -FolderScope Calendar | Select-Object -First 1
        $calendarname = $statistics.Name
        $calendar = "$($mbx.UserPrincipalName):\$calendarname"
    } catch { "Unable to get calendar for $UserPrincipalName`: $_" }

    $SetErrors = @()
    for($i = 0; $i -lt $User.Count; $i++) {
        if($User[$i] -eq "") { continue }
        if('Default','Anonymous' -notcontains $User[$i]) { $User[$i] = "$($User[$i])" }

        try {
            try {
                Set-MailboxFolderPermission -User $User[$i] -AccessRights $AccessRights[$i] -Identity $calendar
            }
            catch {
                Add-MailboxFolderPermission -User $User[$i] -AccessRights $AccessRights[$i] -Identity $calendar 
            }
        } 
        catch { $SetErrors += @("Unable to set calendar permissions on mailbox $UserPrincipalName for user $($User[$i])`: $_") }
        finally {
            if($SetErrors.Count -ne 0) {
                throw ($SetErrors -join '; ')
            }
        }
    }
    
} catch {
    throw $_
}
