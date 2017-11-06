function New-TenantMailbox {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [parameter(Mandatory)]
        [string]$Displayname,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PrimarySmtpAddress,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet("SharedMailbox", "RoomMailbox", "EquipmentMailbox")]
        [string]$Type,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$EmailAddresses
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "New-Mailbox", "Get-Mailbox", "Set-Mailbox") > $null
        
        $Config = Get-SQLEntConfig -Organization $Organization
        $Cred  = Get-RemoteCredentials -Organization $Organization

    }
    Process {
        $Organization = $Organization.ToUpper()

        if ($PrimarySmtpAddress.IndexOf('@') -ne -1) {
            $alias  = $PrimarySmtpAddress.Substring(0, $PrimarySmtpAddress.IndexOf('@'))
            $domain = $PrimarySmtpAddress.Substring($PrimarySmtpAddress.IndexOf('@') + 1)
            if ($alias -eq $null -or $alias -eq '') {
                Write-Error "PrimarySmtpAddress '$PrimarySmtpAddress' does not have a valid alias."
            }
            elseif ($domain -eq $null -or $domain -eq '') {
                Write-Error "PrimarySmtpAddress '$PrimarySmtpAddress' does not have a valid domain."
            }
        }
        else {
            Write-Error "PrimarySmtpAddress '$PrimarySmtpAddress' is not a valid e-mail address."
        }

        # SAMAccountName must be 20 chars or less.
        $SAMAccountName = ($PrimarySmtpAddress.Split('@')[0])
        if ($SAMAccountName.Length -gt 20) {
            $SAMAccountName = $SAMAccountName.Substring(0, 19)
        }

        Write-Verbose "SAMAccountName: $SAMAccountName"

        if ($Config.TenantId -ne "null" -and $Config.ExchangeServer -eq "null") {

            ## Create remote session because of O365 insane throttling...!
            $session = (Get-PSSession -Name "EntExchange")

            if ($Type -eq "SharedMailbox") {

                $Sharedblock = {
                    param ($SAMAccountName, $Displayname, $PrimarySmtpAddress)

                    New-Mailbox -Name $SAMAccountName -DisplayName "$Displayname - Shared" -PrimarySmtpAddress $PrimarySmtpAddress -Shared
                }
                
                $newMbx = Invoke-Command -ScriptBlock $Sharedblock -Session $session -ArgumentList $SAMAccountName, $Displayname, $PrimarySmtpAddress


                if ($EmailAddresses) {
                    foreach ($extraAlias in $EmailAddresses) {
                        Write-Verbose "Adding alias '$($extraAlias)'."
                        $newMbx.EmailAddresses.Add($extraAlias) > $null
                    }

                    $session = Renew-O365session -Organization $Organization
                    Set-Mailbox -Identity $newMbx.Identity -EmailAddresses $newMbx.EmailAddresses
                }
            }

            if ($Type -eq "RoomMailbox") {
                
                $Roomblock = {
                    param ($SAMAccountName, $Displayname, $PrimarySmtpAddress)
                        New-Mailbox -Name $SAMAccountName -DisplayName "$Displayname - Room" -PrimarySmtpAddress $PrimarySmtpAddress -Room
                }

                try {

                    $newMbx = Invoke-Command -ScriptBlock $Roomblock -Session $session -ArgumentList $SAMAccountName, $Displayname, $PrimarySmtpAddress
                }
                catch {

                    throw $_
                }

                try {
                    
                    ## Renew the session to avoid to many throttling issues..
                    $session = Renew-O365session -Organization $Organization
                    Invoke-Command -ScriptBlock {param($newMbx) Set-CalendarProcessing -Identity $newMbx.Identity -AutomateProcessing AutoAccept} -Session $session -ArgumentList $newMbx

                }
                catch{

                    throw $_
                }

            }

            if ($Type -eq "EquipmentMailbox") {
                
                $Eqblock = {
                    param ($SAMAccountName, $Displayname, $PrimarySmtpAddress)

                    New-Mailbox -Name $SAMAccountName -DisplayName "$Displayname - Equipment" -PrimarySmtpAddress $PrimarySmtpAddress -Equipment
                }

                try {

                    $newMbx = Invoke-Command -ScriptBlock $Eqblock -Session $session -ArgumentList $SAMAccountName, $Displayname, $PrimarySmtpAddress
                }
                catch {

                    throw $_
                }

                try {
                    
                    ## Renew the session to avoid to many throttling issues..
                    $session = Renew-O365session -Organization $Organization
                    Invoke-Command -ScriptBlock {param($newMbx) Set-CalendarProcessing -Identity $newMbx.Identity -AutomateProcessing AutoAccept} -Session $session -ArgumentList $newMbx

                }
                catch{

                    throw $_
                }
            }

        }

        if (-not [string]::IsNullOrWhiteSpace($Config.ExchangeServer)) {

            if ($Type -eq "SharedMailbox") {
                $newMbx = New-Mailbox -OrganizationalUnit $Config.CustomerOUDN -Name $SAMAccountName -DisplayName "$Displayname - Shared" -PrimarySmtpAddress $PrimarySmtpAddress -Shared
            }

            if ($Type -eq "RoomMailbox") {

                $newMbx = New-Mailbox -OrganizationalUnit $Config.CustomerOUDN -Name $SAMAccountName -DisplayName "$Displayname - Room" -PrimarySmtpAddress $PrimarySmtpAddress -Room
                Set-CalendarProcessing -Identity $newMbx.Identity -AutomateProcessing AutoAccept
            }

            if ($Type -eq "EquipmentMailbox") {

                $newMbx = New-Mailbox -OrganizationalUnit $Config.CustomerOUDN -Name $SAMAccountName -DisplayName "$Displayname - Equipment" -PrimarySmtpAddress $PrimarySmtpAddress -Equipment
                Set-CalendarProcessing -Identity $newMbx.Identity -AutomateProcessing AutoAccept
            }
        }

        Get-PSSession | Remove-PSSession
    }
}
