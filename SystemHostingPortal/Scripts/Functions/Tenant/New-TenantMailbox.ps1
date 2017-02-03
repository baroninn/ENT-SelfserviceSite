function New-TenantMailbox {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PrimarySmtpAddress,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet("SharedMailbox", "RoomMailbox")]
        [string]$Type,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$EmailAlias
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox", "Enable-Mailbox", "Set-Mailbox", "Update-Recipient", "Add-MailboxPermission", "Add-ADPermission", "Set-CalendarProcessing")
    }
    Process {
        $TenantName = $TenantName.ToUpper()

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

        $Config = Get-TenantConfig -TenantName $TenantName

        try {
            $ou = Get-ADOrganizationalUnit -Identity $Config.UsersOU -Server $Config.DomainFQDN
        }
        catch {
            Write-Error "The tenant '$TenantName' was not found."
        }

        if (-not (Get-TenantAcceptedDomain -DomainName $domain)) {
            Write-Error "Domain '$domain' was not found for the tenant '$TenantName'."
        }

        # SAMAccountName must be 20 chars or less.
        $SAMAccountName = ("{0}_{1}" -f $TenantName, $alias)
        if ($SAMAccountName.Length -gt 20) {
            $SAMAccountName = $SAMAccountName.Substring(0, 19)
        }

        Write-Verbose "SAMAccountName: $SAMAccountName"

        $newUserParams = @{
            Name              = $Name
            Enabled           = $false
            SamAccountName    = $SAMAccountName
            DisplayName       = $Name
            Path              = $Config.UsersOU
            UserPrincipalName = $PrimarySmtpAddress
            Server            = $Config.DomainFQDN
            PassThru          = $null
        }
        $enableMailboxParams = @{
            Identity           = $SAMAccountName
            PrimarySMTPAddress = $PrimarySmtpAddress
        }
        $setMailboxParams = @{
            Identity                  = $SAMAccountName
            EmailAddressPolicyEnabled = $false
            CustomAttribute1          = "$TenantName"
            AddressBookPolicy         = "$TenantName"
        }

        switch ($Type) {
            "SharedMailbox" {
                $enableMailboxParams.Add("Shared", $null)
            }
            "RoomMailbox" {
                $enableMailboxParams.Add("Room", $null)
            }
            default {
                Write-Error "Unknown type '$Type'."
            }
        }

        Write-Verbose "Creating user '$SAMAccountName'..."
        $newUser = New-ADUser @newUserParams

        $groupFullAccessName = "$($TenantName)_Mailbox_$($PrimarySmtpAddress)_FullAccess"
        $groupSendAsName     = "$($TenantName)_Mailbox_$($PrimarySmtpAddress)_SendAs"

        Write-Verbose "Creating AD group '$groupFullAccessName'..."
        $groupFullAccess = New-ADGroup -Name $groupFullAccessName -GroupCategory Security -GroupScope Universal -Path $Config.MailboxGroupsOU -Server $Config.DomainFQDN -PassThru
        
        if ($Type -eq "SharedMailbox") {
            Write-Verbose "Creating AD group '$groupSendAsName'..."
            $groupSendAs = New-ADGroup -Name $groupSendAsName -GroupCategory Security -GroupScope Universal -Path $Config.MailboxGroupsOU -Server $Config.DomainFQDN -PassThru    
        }  

        Wait-ADReplication -DistinguishedName $newUser.DistinguishedName -DomainName $Config.DomainFQDN

        Write-Verbose "Enabling mailbox for '$PrimarySmtpAddress'..."
        $newMbx = Enable-Mailbox @enableMailboxParams
        if ($newMbx) {
            Set-Mailbox @setMailboxParams
            Update-Recipient –Identity $SAMAccountName
        }
        else {
            Write-Error "Error enabling mailbox for '$($SAMAccountName)'."
        }
        
        Wait-ADReplication -DistinguishedName $groupFullAccess.DistinguishedName -DomainName $Config.DomainFQDN

        Write-Verbose "Adding FullAccess to mailbox for '$groupFullAccessName'..."
        $newMbx | Add-MailboxPermission -AccessRights FullAccess -User $groupFullAccessName | Out-Null

        switch ($Type) {
            "SharedMailbox" {

                Wait-ADReplication -DistinguishedName $groupSendAs.DistinguishedName -DomainName $Config.DomainFQDN

                Write-Verbose "Adding SendAs to mailbox for $groupSendAsName"
                $newMbx | Add-ADPermission -ExtendedRights Send-As -User $groupSendAsName | Out-Null
                
                if ($EmailAlias) {
                    foreach ($extraAlias in $EmailAlias) {
                        Write-Verbose "Adding alias '$($extraAlias)'."
                        $newMbx.EmailAddresses.Add($extraAlias) | Out-Null
                    }

                    Set-Mailbox -Identity $SAMAccountName -EmailAddresses $newMbx.EmailAddresses
                }
            }
            "RoomMailbox" {
                $newMbx | Set-CalendarProcessing -AutomateProcessing AutoAccept
            }
            default {
                Write-Error "Unknown type '$Type'."
            }
        }
    }
}