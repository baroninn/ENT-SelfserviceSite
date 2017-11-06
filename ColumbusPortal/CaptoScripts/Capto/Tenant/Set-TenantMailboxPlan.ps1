function Set-TenantMailboxPlan {
    [Cmdletbinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1')]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="MailboxPlan")]
        [ValidateSet("2GB", "5GB", "10GB", "15GB", "20GB", "25GB", "30GB", "35GB", "40GB", "45GB", "50GB", "55GB", "60GB", "65GB", "70GB", "75GB", "80GB", "85GB", "90GB", "95GB", "100GB", "110GB", "120GB")]
        [string]$MailboxPlan,

        [Parameter(Mandatory, ParameterSetName="AutoMailboxPlan")]
        [switch]$AutoSize,

        [Parameter(DontShow)]
        [string]$OldSize = "Unlimited"
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
        
        Import-Module (New-ExchangeProxyModule -Command 'Set-Mailbox', 'Get-MailboxStatistics')
    }

    Process {
        $mbx = Get-TenantMailbox -TenantName $TenantName -Name $Name -Single
        Write-Verbose "Processing $($mbx.DisplayName)"

        if ($AutoSize) {
            try {
                if ($mbx.ShtProperties.ExcludeFromMailboxAutoResize) {
                    Write-Warning "Mailbox '$($mbx.DisplayName)' is excluded from auto resizing"
                    return
                }
            } catch {}

            $stats = $mbx | Get-MailboxStatistics

            if($stats -eq $null) {
                Write-Verbose "Stats null, setting Plan10"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 10GB -OldSize 'Null'
                return
            }

            $statsHacked = $stats.TotalItemSize.Value.ToString().Split(' ')
            if($statsHacked[1] -eq 'GB') { $itemSize = [double]$statsHacked[0] * 1024*1024*1024 }
            if($statsHacked[1] -eq 'MB') { $itemSize = [double]$statsHacked[0] * 1024*1024 }
            if($statsHacked[1] -eq 'KB') { $itemSize = [double]$statsHacked[0] * 1024 }

            Write-Verbose "Mailbox size: $($itemSize) bytes ($($statsHacked[0] + $statsHacked[1]))"
            
            $oldMailboxPlanStats = $mbx.ProhibitSendReceiveQuota.Split(' ')
            $oldMailboxPlanName  = "$($oldMailboxPlanStats[0])$($oldMailboxPlanStats[1])"

            if($itemSize -le 1.5GB) {
                Write-Verbose "Setting Plan2"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 2GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 3GB) {
                Write-Verbose "Setting Plan5"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 5GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 8GB) {
                Write-Verbose "Setting Plan10"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 10GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 13GB) {
                Write-Verbose "Setting Plan15"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 15GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 18GB) {
                Write-Verbose "Setting Plan20"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 20GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 23GB) {
                Write-Verbose "Setting Plan25"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 25GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 28GB) {
                Write-Verbose "Setting Plan30"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 30GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 33GB) {
                Write-Verbose "Setting Plan35"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 35GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 38GB) {
                Write-Verbose "Setting Plan40"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 40GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 43GB) {
                Write-Verbose "Setting Plan45"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 45GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 48GB) {
                Write-Verbose "Setting Plan50"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 50GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 53GB) {
                Write-Verbose "Setting Plan55"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 55GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 58GB) {
                Write-Verbose "Setting Plan60"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 60GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 63GB) {
                Write-Verbose "Setting Plan65"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 65GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 68GB) {
                Write-Verbose "Setting Plan70"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 70GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 73GB) {
                Write-Verbose "Setting Plan75"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 75GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 78GB) {
                Write-Verbose "Setting Plan80"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 80GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 83GB) {
                Write-Verbose "Setting Plan85"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 85GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 88GB) {
                Write-Verbose "Setting Plan90"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 90GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 93GB) {
                Write-Verbose "Setting Plan95"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 95GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 98GB) {
                Write-Verbose "Setting Plan100"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 100GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 108GB) {
                Write-Verbose "Setting Plan110"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 110GB -OldSize $oldMailboxPlanName
            }
            elseif($itemSize -le 118GB) {
                Write-Verbose "Setting Plan120"
                $mbx | Set-TenantMailboxPlan -MailboxPlan 120GB -OldSize $oldMailboxPlanName
            }
            else {
                Write-Error "User $($mbx.DisplayName) ($($mbx.UserPrincipalName)) did not receive a new mailboxplan because TotalItemSize was out of bounds: $($stats.TotalItemSize.Value)"
            }
        }
        else {
            Write-Verbose "Setting mailbox plan to '$MailboxPlan' for '$Name'..."
            [int64]$newSize = $MailboxPlan.Replace('GB', '')
            $newSize = $newSize * 1024 * 1024 * 1024 # From GB to bytes
 
            $prohibitSendReceive = $newSize * 1
            $prohibitSend = $newSize * 0.999
            $issueWarning = $newSize * 0.98
            if ($PSCmdlet.ShouldProcess($Name, "Set-MailboxPlan: '$OldSize' to '$MailboxPlan'")) {
                Set-Mailbox -Identity $mbx.SamAccountName -ProhibitSendReceiveQuota $prohibitSendReceive -ProhibitSendQuota $prohibitSend -IssueWarningQuota $issueWarning -UseDatabaseQuotaDefaults $false
            }
        }
    }
}