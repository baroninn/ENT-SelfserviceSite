#requires -version 3

function New-BillingObject {
    [Cmdletbinding()]
    param()

    Begin {
    }
    Process {
        [pscustomobject]@{
            Files = [pscustomobject]@{
                TotalAllocated = 0
                TotalUsage     = 0
            }
            Mailbox = [pscustomobject]@{
                TotalAllocated = 0
                TotalUsage     = 0
                Users = @()
            }
            Database = [pscustomobject]@{
                TotalUsage = 0
            }

            Office365 = [pscustomobject]@{
                Info = @()
            }
            Sikkermail = [pscustomobject]@{
                Groups = @()
            }
        }
    }
}

function New-MailboxUserBillingObject {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            DisplayName        = $null
            PrimarySmtpAddress = $null
            SAMAccountName     = $null
            Type               = $null
            Disabled           = $false
            TestUser           = $false
            StudJur            = $false
            MailOnly           = $false
            TotalAllocated     = 0
            TotalUsage         = 0
        }
    }
}

function New-Office365BillingObject {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            TenantID           = $null
            License            = $null
            Admin              = $null
            PartnerName        = $null
        }
    }
}

function New-SikkermailBillingObject {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            Name              = $null
            Description       = $null
        }
    }
}

function Get-TenantBillingInformation {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1', 'Organization')]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$FileServer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$FilePath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='SQL')]
        [string]$DatabaseServer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='Native')]
        [string]$NativeDatabaseServer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='Native')]
        [string]$NativeDatabasePath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DomainName
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Start-VerboseEx

        if ($DatabaseServer) {
            Import-Module SQLPS
        }
        Import-Module (New-ExchangeProxyModule -Command 'Get-MailboxStatistics')
    }

    Process {
        $Config = Get-TenantConfig -TenantName $TenantName
        $stats = New-BillingObject
        
        try {
            $quota = Get-FsrmQuota -Path $FilePath -CimSession $FileServer -ErrorAction 'Stop'
            $stats.Files.TotalAllocated = $quota.Size
            $stats.Files.TotalUsage     = $quota.Usage
        }
        catch {
            if ($_.CategoryInfo.Category -eq 'ResourceUnavailable') {
                Write-Error "Unable to connect to $FileServer"
            }
            else {
                Write-VerboseEx "No quota found for '$FilePath' on $FileServer"
                $stats.Files.TotalAllocated = 0
                $stats.Files.TotalUsage = 0
            }
        }

        $sikkermailStats = New-SikkermailBillingObject
        $SikkermailGroups = Get-ADGroup -Server hosting.capto.dk -Filter 'Description -eq "SikkerMail"' -Properties Description -SearchBase $Config.OUs[7].path
        if (-not $SikkermailGroups) {
            Write-Verbose "No groups found.."

        }
        else {
            foreach ($group in $SikkermailGroups) {
            $newGroup = New-SikkermailBillingObject
            $newGroup.Name        += $group.Name
            $newGroup.Description += $group.Description
            }
            $stats.Sikkermail.Groups += $newGroup
        }

        Write-VerboseEx "Finding mailboxes..."
        $mailboxes = Get-TenantMailbox -TenantName $TenantName
        Write-VerboseEx "Done."

        Write-VerboseEx "Processing mailboxes..."
        foreach ($mbx in $mailboxes) {
            Write-VerboseEx "  Processing $($mbx.PrimarySmtpAddress)..."
            $newMbx = New-MailboxUserBillingObject

            Write-VerboseEx "    Getting statistics..."
            $mbxStats = $mbx | Get-MailboxStatistics
            Write-VerboseEx "    Done."

            if ($mbxStats -eq $null) {
                $newMbx.TotalUsage = 0
            }
            else {
                # Converts the byte size between () from Exchange output to an integer
                $newSize = $mbxStats.TotalItemSize.Value.ToString()
                $newMbx.TotalUsage = [int64]$newSize.Substring($newSize.IndexOf('(')).Split(' ')[0].Substring(1).Replace(',', '').Replace('.', '')
            }

            Write-VerboseEx "    Getting mailboxplan..."
            $allocatedSize = Get-TenantMailboxPlan -TenantName $TenantName -Name $mbx.PrimarySmtpAddress
            Write-VerboseEx "    Done."

            if ($allocatedSize -eq 'Unlimited') {
                $newMbx.TotalAllocated = 0
            }
            else {
                switch -Wildcard ($allocatedSize) {
                    "*KB" {
                        $newMbx.TotalAllocated = [int64]$allocatedSize.Substring(0, $allocatedSize.Length - 2) * 1024
                    }
                    "*MB" {
                        $newMbx.TotalAllocated = [int64]$allocatedSize.Substring(0, $allocatedSize.Length - 2) * 1024 * 1024
                    }
                    "*GB" {
                        $newMbx.TotalAllocated = [int64]$allocatedSize.Substring(0, $allocatedSize.Length - 2) * 1024 * 1024 * 1024
                    }
                    Default {
                        Write-Error "Unknown allocated size '$allocatedSize'"
                    }
                }
            }

            Write-VerboseEx "    Testing if user is disabled..."
            $newMbx.Disabled = Test-ADUserDisabled -DistinguishedName $mbx.DistinguishedName -Server $DomainName
            Write-VerboseEx "    Done."

            $newMbx.DisplayName        = $mbx.DisplayName
            $newMbx.PrimarySmtpAddress = $mbx.PrimarySmtpAddress
            $newMbx.SAMAccountName     = $mbx.SamAccountName
            $newMbx.Type               = $mbx.RecipientTypeDetails
            $newMbx.TestUser           = if ($mbx.CustomAttribute2 -eq 'TestUser') {$true} else {$false}
            $newMbx.StudJur            = @(Get-ADGroupMember -Identity $Config.StudJurRoleGroupName -Server $DomainName | where SamAccountName -eq $newMbx.SAMAccountName).Count -eq 1
            # User must only be a member of MailOnly and NOT User Role group to qualify as a MailOnly user
            $newMbx.MailOnly           = ((@(Get-ADGroupMember -Identity $Config.MailOnlyRoleGroupName -Server $DomainName | where SamAccountName -eq $newMbx.SAMAccountName).Count -eq 1) -and (@(Get-ADGroupMember -Identity $Config.UserRoleGroupName -Server $DomainName | where SamAccountName -eq $newMbx.SAMAccountName).Count -eq 0))

            $stats.Mailbox.Users += ($newMbx)
            
            # Test users does not count as usage for a customer
            if ($newMbx.TestUser) {
                $newMbx.DisplayName = "$($newMbx.DisplayName) [TEST USER]"
            }
            elseif ($newMbx.Disabled) {
                    $newMbx.DisplayName = "$($newMbx.DisplayName) [DISABLED]" 
            }
            
            else{
                $stats.Mailbox.TotalAllocated += $newMbx.TotalAllocated
                $stats.Mailbox.TotalUsage     += $newMbx.TotalUsage
            }

            Write-VerboseEx "  Done for $($mbx.PrimarySmtpAddress)."
        }
        Write-VerboseEx "Done."

        ## Get Office365 information

        $stats.Office365.Info = @(Get-Office365Information -TenantName $TenantName)


        ## Database report:
        if ($DatabaseServer) {
            Write-VerboseEx "Invoking SQL query..."
            $dbSizes = Invoke-Sqlcmd -ServerInstance $DatabaseServer -Query 'sp_databases'
            Write-VerboseEx "Done."

            try {
                $stats.Database.TotalUsage = $dbSizes.Where{$_.DATABASE_NAME -eq $TenantName}.DATABASE_SIZE * 1024 # It's reported in KB by SQL
            }
            catch {
                Write-VerboseEx "Unable to find SQL database"
                $stats.Database.TotalUsage = 0 
            }
        }
        else {
            $_nativeDbUncPath = Resolve-UncPath -LocalPath $NativeDatabasePath -ComputerName $NativeDatabaseServer

            if (Test-Path $_nativeDbUncPath) {
                $stats.Database.TotalUsage = (Get-Item $_nativeDbUncPath).Length
            }
            else {
                Write-VerboseEx "Unable to find native DB size for '$_nativeDbUncPath'."
                $stats.Database.TotalUsage = 0
            }
        }

        $stats
    }

    End {
        Stop-VerboseEx
    }
}