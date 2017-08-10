param(
    [Parameter(Mandatory)]
    $Organization,
    [Parameter(Mandatory)]
    $UserPrincipalName
)
    Import-Module (Join-Path $PSScriptRoot "Functions")

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2

    Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Get-Mailbox","Get-MailboxFolderPermission","Get-MailboxFolderStatistics")
    $Config = Get-SQLEntConfig -Organization $Organization
    $Cred = Get-RemoteCredentials -Organization $Organization
try {
    
    $mbx = Get-TenantMailbox -Organization $Organization -Name $UserPrincipalName -Single
    if($mbx.UserPrincipalName -ne $UserPrincipalName) {
        throw "Found user $($mbx.UserPrincipalName) does not match identity $UserPrincipalName - Please try to be more specific"
    }

    try {
        $statistics = $mbx | Get-MailboxFolderStatistics -FolderScope Calendar | Select-Object -First 1
        $calendarname = $statistics.Name
        $calendar = "$($mbx.Alias):\$calendarname"

    } 
    catch { 
        throw "Unable to get calendar for $UserPrincipalName : $_" 
    }

    #Renew-O365session -Organization $Organization

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
            if ($User.User.DisplayName -notlike "*NT:S-1-5*") {
            $ADUser = Get-ADUser -Filter "DisplayName -eq '$($user.User)'" -Server $Config.DomainFQDN -Credential $Cred
            $CalendarPermissions += [pscustomobject]@{
                            User         = $ADUser.UserPrincipalName
                            AccessRights = $user.AccessRights
                            }
            }
            else {
                $CalendarPermissions += [pscustomobject]@{
                            User         = $User.User.DisplayName
                            AccessRights = $user.AccessRights
                            }
            }
        }
    }

    return $CalendarPermissions
    #return $Users
    #Get-PSSession | Remove-PSSession
} catch {
    throw $_
}
