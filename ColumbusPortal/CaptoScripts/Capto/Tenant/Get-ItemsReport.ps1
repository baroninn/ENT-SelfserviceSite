function Get-ItemsReport {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Mail,
        [string]$Organization,
        [switch]$GetALL

        
    )

    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version 2
    Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox","Get-MailboxFolderStatistics","Get-MailboxStatistics")

    if($GetALL){
                
        $info = @()
            $Mailbox = Get-Mailbox -ResultSize 10000 | where{$_.RecipientTypeDetails -eq 'UserMailbox' -xor $_.RecipientTypeDetails -eq 'SharedMailbox' }
            foreach($box in $mailbox){

                    $Folders = $box | Get-MailboxFolderStatistics
                    $BigFolders = @($Folders | where{$_.ItemsInFolder -gt '30000'})
                    $Biggest = $folders | Sort-Object ItemsInFolder | select -Last 1
                    $stats   = $box | Get-MailboxStatistics
                    if($BigFolders){
                    $object  = New-Object PSObject
                                Add-Member -InputObject $object -MemberType NoteProperty -Name Customer -Value $box.CustomAttribute1
                                Add-Member -InputObject $object -MemberType NoteProperty -Name User -Value $box.DisplayName
                                Add-Member -InputObject $object -MemberType NoteProperty -Name Initialer -Value $box.alias
                                Add-Member -InputObject $object -MemberType NoteProperty -Name Server -Value $box.ServerName
                                Add-Member -InputObject $object -MemberType NoteProperty -Name Database -Value $box.Database
                                Add-Member -InputObject $object -MemberType NoteProperty -Name ItemsTotal -Value $stats.ItemCount
                                Add-Member -InputObject $object -MemberType NoteProperty -Name ItemsTotalSize -Value $stats.TotalItemSize
                                Add-Member -InputObject $object -MemberType NoteProperty -Name FolderCount -Value $Folders.count
                                if($BigFolders -ne $null){
                                Add-Member -InputObject $object -MemberType NoteProperty -Name FoldersOver30K -Value $BigFolders.count}
                                Add-Member -InputObject $object -MemberType NoteProperty -Name BiggestFolderName -Value $Biggest.Name
                                Add-Member -InputObject $object -MemberType NoteProperty -Name BiggestFolderCount -Value $Biggest.ItemsInFolder
                                Add-Member -InputObject $object -MemberType NoteProperty -Name BiggestFolderPath -Value $Biggest.FolderPath
                                $info += $object}

                        }

                ## Generate HTML Table styles
                $style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
                $style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
                $style = $style + "TH{border: 1px solid black; background: #58FA82; padding: 10px; }"
                $style = $style + "TD{border: 1px solid black; padding: 10px; text-align: right; }"
                $style = $style + "</style>"

                $Report = $info | Sort-Object Customer, BiggestFolderCount | ConvertTo-Html -Head $style

                if($info){

                        Send-MailMessage -SmtpServer "relay.systemhosting.dk" `
                                            -BodyAsHtml `
                                            -From "jst@systemhosting.dk" `
                                            -To "$Mail" `
                                            -Body "$Report" `
                                            -Subject "Capto Exchange Items Report"
                }
    }
    
    elseif($Organization -and -not $GetALL){

        $Config = Get-TenantConfig -TenantName $Organization
        
        $info = @()
            $Users = Get-ADUser -Filter {extensionAttribute1 -eq $Organization} `
                                -SearchBase "OU=customer,OU=systemhosting,DC=hosting,DC=capto,DC=dk" `
                                -SearchScope Subtree -Server $Config.DomainFQDN

            $Mailbox = foreach($user in $users){Get-Mailbox $user.SamAccountName}

                foreach($box in $Mailbox){

                        $Folders = $box | Get-MailboxFolderStatistics
                        $BigFolders = @($Folders | where{$_.ItemsInFolder -gt '30000'})
                        $Biggest = $folders | Sort-Object ItemsInFolder | select -Last 1
                        $stats   = $box | Get-MailboxStatistics
                        $object  = New-Object PSObject
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name Customer -Value $Organization
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name User -Value $box.DisplayName
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name Initialer -Value $box.alias
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name Server -Value $box.ServerName
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name Database -Value $box.Database
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name ItemsTotal -Value $stats.ItemCount
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name ItemsTotalSize -Value $stats.TotalItemSize
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name FolderCount -Value $Folders.count
                                   if($BigFolders -ne $null){
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name FoldersOver30K -Value $BigFolders.count}
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name BiggestFolderName -Value $Biggest.Name
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name BiggestFolderCount -Value $Biggest.ItemsInFolder
                                   Add-Member -InputObject $object -MemberType NoteProperty -Name BiggestFolderPath -Value $Biggest.FolderPath
                                   $info += $object

                            }

                    ## Generate HTML Table styles
                    $style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
                    $style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
                    $style = $style + "TH{border: 1px solid black; background: #58FA82; padding: 10px; }"
                    $style = $style + "TD{border: 1px solid black; padding: 10px; text-align: right; }"
                    $style = $style + "</style>"

                    $Report = $info | Sort-Object Server, BiggestFolderCount | ConvertTo-Html -Head $style

                    if($info){

                            Send-MailMessage -SmtpServer "relay.systemhosting.dk" `
                                             -BodyAsHtml `
                                             -From "jst@systemhosting.dk" `
                                             -To "$Mail" `
                                             -Body "$Report" `
                                             -Subject "Capto Exchange Items Report"
               }
       }

}