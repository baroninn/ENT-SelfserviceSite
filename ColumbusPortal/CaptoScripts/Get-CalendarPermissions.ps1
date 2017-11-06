param(
    [Parameter(Mandatory)]
    $Organization,
    [Parameter(Mandatory)]
    $UserPrincipalName
)
    Import-Module (Join-Path $PSScriptRoot Capto)

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2

    Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox","Get-MailboxFolderPermission","Get-MailboxFolderStatistics")


try {

    $mbx = Get-TenantMailbox -TenantName $Organization -Name $UserPrincipalName -Single
    if($mbx.UserPrincipalName -ne $UserPrincipalName) {
        throw "Found user $($mbx.UserPrincipalName) does not match identity $UserPrincipalName - Please try to be more specific"
    }

    try {
        $statistics = $mbx | Get-MailboxFolderStatistics -FolderScope Calendar | Select-Object -First 1
        $calendarname = $statistics.Name
        $calendar = "$($mbx.UserPrincipalName):\$calendarname"

    } catch { throw "Unable to get calendar for $UserPrincipalName : $_" }

    $CalendarPermissions = @()
    $Users = Get-MailboxFolderPermission $calendar | select User, AccessRights

    foreach($user in $users) {

        if($User.User.DisplayName -eq 'Default'){
                    $CalendarPermissions += [pscustomobject]@{
                                User         = 'Default'
                                AccessRights = $user.AccessRights
                                }
            }
        elseif($User.User.DisplayName -eq 'Anonymous'){
                    $CalendarPermissions += [pscustomobject]@{
                                User         = 'Anonymous'
                                AccessRights = $user.AccessRights
                                }
        }
        else{

                $usermbx = Get-TenantMailbox -TenantName $Organization -Name $user.User -Single
                $CalendarPermissions += [pscustomobject]@{
                                User         = $usermbx.UserPrincipalName
                                AccessRights = $user.AccessRights
                                }
        }
    }

    return $CalendarPermissions

} catch {
    throw $_
}
