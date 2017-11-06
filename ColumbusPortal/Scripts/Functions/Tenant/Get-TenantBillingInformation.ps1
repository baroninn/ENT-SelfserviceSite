#requires -version 3

function New-BillingObject {
    [Cmdletbinding()]
    param()

    Begin {
    }
    Process {
        [pscustomobject]@{
            FileServer = [pscustomobject]@{
                Allocated = 0
                FreeSpace = 0
                Used      = 0
            }
            Totalstorage = [pscustomobject]@{
                TotalAllocated = 0
            }
            ADUser = [pscustomobject]@{
                Users = @()
            }
            Server = [pscustomobject]@{
                Servers = @()
            }
            Database = [pscustomobject]@{
                TotalUsage = 0
            }

            Office365 = [pscustomobject]@{
                Info = @()
            }
        }
    }
}

function New-ADUserBillingObject {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            DisplayName        = $null
            PrimarySmtpAddress = 'null'
            SAMAccountName     = $null
            Type               = $null
            Disabled           = $false
            TestUser           = $false
            LightUser          = $false
        }
    }
}

function New-ENTServerBillingObject {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            Name            = $null
            OperatingSystem = $null
            Memory          = 0
            CPUCount        = 0
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

function Get-TenantBillingInformation {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Cmdlets = @("Get-SCVMMServer", "Get-SCVirtualMachine", "Get-SCCloud")
        $SCVMMServer= 'vmm-a.corp.systemhosting.dk'
        $Cred = Get-RemoteCredentials -SSS

        import-module "C:\Program Files\Microsoft System Center 2016\Virtual Machine Manager\bin\Microsoft.SystemCenter.VirtualMachineManager.dll" -Cmdlet $Cmdlets
        <#
        $module = Get-Module virtualmachinemanager -ErrorAction SilentlyContinue
        if (-not $module) {
            Import-Module virtualmachinemanager -Cmdlet $Cmdlets -DisableNameChecking -Force | Out-Null
        }
        $SCVMMServer = Get-SCVMMServer -ConnectAs Administrator -ComputerName $Server -Credential $Cred
        #>
    }

    Process {
        
        $Config = Get-SQLEntConfig -Organization $Organization

        ## Get server information
        $Cloud = Get-SCCloud -VMMServer $SCVMMServer | where{$_.Name -like "$Organization*"}
        $vms  = Get-SCVirtualMachine -VMMServer $SCVMMServer -Cloud $Cloud | where {$_.CostCenter -eq $Organization -and $_.Status -eq "Running"} | sort Name | select Name, OperatingSystem, Memory, CPUCount, DynamicMemoryMaximumMB, DynamicMemoryEnabled
        $Cred  = Get-RemoteCredentials -Organization $Organization

        $stats = New-BillingObject

        if ($vms -ne $null) {
            Write-Verbose "Servers found, continuing.."
        }
        else {
            throw "No servers found.. Are the VMM servers 'cost center' attribute filled out with $Organization ?"
        }
        
        ## All Storage stats
        $TotalStorage=@()
            foreach($server in $VMs){

            $newServer = New-ENTServerBillingObject
            $newServer.CPUCount        = [int64][scriptblock]::Create($server.CPUCount).Invoke()[0]
            $newServer.Name            = $server.Name
            $newServer.OperatingSystem = $server.OperatingSystem.Name

            if($server.DynamicMemoryEnabled -eq $false){
                $newServer.Memory      = [int64][scriptblock]::Create($server.Memory).Invoke()[0]}
            else{$newServer.Memory     = [int64][scriptblock]::Create($server.DynamicMemoryMaximumMB).Invoke()[0]}

            $stats.Server.Servers += ($newServer)
                
                try{
                
                    Write-Verbose "Trying CIMSession on $($server.name)"
                    $session = New-CimSession -ComputerName "$($server.name).$($Config.DomainFQDN)" -Credential $Cred -Name $server.Name

                    $volumes = Get-CimInstance -CimSession $session -Query "SELECT * FROM Win32_Volume" | 
                                where{$_.Capacity -notlike $null -and 
                                        $_.Name -notlike "C:\" -and 
                                        $_.Label -notlike "User Disk" -and 
                                        $_.Label -notlike "SwapDisk"} | 
                                select Name, Label, PSComputername, @{label="Capacity";expression={[int64](([int64]($_.Capacity)/1073741824))}}, @{label="FreeSpace";expression={[int64](([int64]($_.FreeSpace)/1073741824))}}

                    foreach($volume in $volumes){
          
                              $object = New-Object PSObject
                                        Add-Member -InputObject $object -MemberType NoteProperty -Name Server -Value $server.name
                                        Add-Member -InputObject $object -MemberType NoteProperty -Name Capacity -Value $volume.Capacity
                                        Add-Member -InputObject $object -MemberType NoteProperty -Name FreeSpace -Value $volume.FreeSpace
                                        Add-Member -InputObject $object -MemberType NoteProperty -Name Disk -Value $volume.Name
                                        Add-Member -InputObject $object -MemberType NoteProperty -Name DiskName -Value $volume.Label
                                        $TotalStorage += $object
                                                }
                            Get-CimSession -Name $server.name | Remove-CimSession
                            
                }
                catch{
                        Write-Verbose ("Server " +  $server.name + " not accessible")
                }
            }

        $stats.Totalstorage.TotalAllocated = $TotalStorage.Capacity | Measure-Object -Sum | select -ExpandProperty sum

        ## File server specific info
        $FileServerStorage=@()
        try{
            if($Organization -eq "ASG") {
                $session = New-CimSession -ComputerName "$Organization-file01.$($Config.DomainFQDN)" -Authentication Negotiate -Credential $Cred
            }
            else{
                $session = New-CimSession -ComputerName "$Organization-file-01.$($Config.DomainFQDN)" -Authentication Negotiate -Credential $Cred
            }

            $volumes = Get-CimInstance -CimSession $session -Query "SELECT * FROM Win32_Volume" | 
                        where{$_.Capacity -notlike $null -and 
                              $_.Label -like "Data"} | 
                        select Name, Label, PSComputername, @{label="Capacity";expression={[int64](([int64]($_.Capacity)/1073741824))}}, @{label="FreeSpace";expression={[int64](([int64]($_.FreeSpace)/1073741824))}}

            foreach($volume in $volumes){
          
                      $object = New-Object PSObject
                                Add-Member -InputObject $object -MemberType NoteProperty -Name Capacity -Value $volume.Capacity
                                Add-Member -InputObject $object -MemberType NoteProperty -Name FreeSpace -Value $volume.FreeSpace
                                Add-Member -InputObject $object -MemberType NoteProperty -Name Disk -Value $volume.Name
                                Add-Member -InputObject $object -MemberType NoteProperty -Name DiskName -Value $volume.Label
                                $FileServerStorage += $object
                                        }
                    Get-CimSession | Remove-CimSession
                            
        }
        catch{
                Write-Verbose ("Server not accessible")
        }
        
        $stats.FileServer.Allocated = $FileServerStorage.Capacity | Measure-Object -Sum | select -ExpandProperty sum
        $stats.FileServer.FreeSpace = $FileServerStorage.FreeSpace | Measure-Object -Sum | select -ExpandProperty sum
        $stats.FileServer.Used = ($FileServerStorage.Capacity - $FileServerStorage.FreeSpace)

        ## ADuser stats..
        Write-Verbose "Finding AD users.."

        Import-Module ActiveDirectory -Cmdlet "Get-ADGroupMember", "Get-ADUser"

        $FullUsers  = Get-ADGroupMember -Credential $Cred -Server $Config.DomainDC -Identity G_FullUsers
        $LightUsers = Get-ADGroupMember -Credential $Cred -Server $Config.DomainDC -Identity G_LightUsers

        $FullADObjects = foreach ($i in $FullUsers) {
        Get-ADUser -Credential $Cred -Server $Config.DomainDC -Identity $i.distinguishedName -Properties Name, DisplayName, Enabled, SamAccountName, UserPrincipalName, EmailAddress, proxyAddresses, ObjectClass | where{$_.Enabled -eq $true -and $_.DisplayName -notlike "*test*"}
        }

        foreach ($user in $FullADObjects) {
            $newFulluser = New-ADUserBillingObject
            
            $newFulluser.Disabled           = $user.Enabled
            $newFulluser.DisplayName        = $user.DisplayName

            if (-not $user.EmailAddress) {

                if (-not $user.proxyAddresses) {
                    $newFulluser.PrimarySmtpAddress = 'Null'
                }
                elseif ($user.proxyAddresses -clike "SMTP:*") {
                    $newFulluser.PrimarySmtpAddress = ($user.proxyAddresses -clike "SMTP:*").split(':')[1]
                }
                else {
                    $newFulluser.PrimarySmtpAddress = ($user.proxyAddresses -clike "smtp:*")[0]
                }
            }
            else {
                $newFulluser.PrimarySmtpAddress = $user.EmailAddress
            }

            $newFulluser.SAMAccountName     = $user.SamAccountName
            $newFulluser.Type               = $user.ObjectClass
            $newFulluser.LightUser          = $false

            $stats.ADUser.Users += ($newFulluser | sort DisplayName)
        }

        $LightADObjects = foreach ($i in $LightUsers) {
        Get-ADUser -Credential $Cred -Server $Config.DomainDC -Identity $i.distinguishedName -Properties Name, DisplayName, Enabled, SamAccountName, UserPrincipalName, EmailAddress, proxyAddresses, ObjectClass | where{$_.Enabled -eq $true -and $_.DisplayName -notlike "*test*"}
        }

        foreach ($user in $LightADObjects) {
            $newLightuser = New-ADUserBillingObject
            
            $newLightuser.Disabled           = $user.Enabled
            $newLightuser.DisplayName        = $user.DisplayName

            if (-not $user.EmailAddress) {

                if (-not $user.proxyAddresses) {
                    $newLightuser.PrimarySmtpAddress = 'Null'
                }
                elseif ($user.proxyAddresses -clike "SMTP:*") {
                    $newLightuser.PrimarySmtpAddress = ($user.proxyAddresses -clike "SMTP:*").split(':')[1]
                }
                else {
                    $newLightuser.PrimarySmtpAddress = ($user.proxyAddresses -clike "smtp:*")[0]
                }
            }
            else {
                $newLightuser.PrimarySmtpAddress = $user.EmailAddress
            }

            $newLightuser.SAMAccountName     = $user.SamAccountName
            $newLightuser.Type               = $user.ObjectClass
            $newLightuser.LightUser          = $true

            $stats.ADUser.Users += ($newLightuser | sort DisplayName)
        }

        $stats.ADUser.Users = ($stats.ADUser.Users | sort DisplayName)

        <#
        Write-VerboseEx "Finding mailboxes..."
        $mailboxes = Get-TenantMailbox -Organization $Organization
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
            $allocatedSize = $mbx | Get-TenantMailboxPlan
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
        #>

        $stats.Office365.Info = @(Get-Office365Information -Organization $Organization)

<#
        if ($DatabaseServer) {
            Write-VerboseEx "Invoking SQL query..."
            $dbSizes = Invoke-Sqlcmd -ServerInstance $DatabaseServer -Query 'sp_databases'
            Write-VerboseEx "Done."

            try {
                $stats.Database.TotalUsage = $dbSizes.Where{$_.DATABASE_NAME -eq $Organization}.DATABASE_SIZE * 1024 # It's reported in KB by SQL
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
#>
        Get-PSSession | Remove-PSSession
        $stats
    }

}