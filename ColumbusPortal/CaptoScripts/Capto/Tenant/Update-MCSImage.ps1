Function Update-MCSImage {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("AdvoPlus", "Legal", "Member2015")]
        [string]$Solution,
        [string]$VMName,
        [switch]$All

    )

    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version 2
    $CTXServer = "cpo-ctx-01.hosting.capto.dk"
    $VMMServer = 'CPO-VMM-01.hosting.capto.dk'
    $Cred = Get-RemoteCredentials -CPO
    
    if (-not $All) {
        ## Start with shutting down the virtual machine. This is done before the snapshot is taking place..
        $VMMShutdown = {
                param ($VMMServer, $VMName)

                Import-Module virtualmachinemanager
                $VM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $VMName

                if ($VM.Status -eq "Running") {
                    Stop-SCVirtualMachine -VM $VM -Shutdown | Out-Null
                }
                #return $Latest.Name
        }
        ## Run invoke before CTXBlock so Latest variable will be filled..
        $Latest = Invoke-Command -ComputerName $VMMServer -ScriptBlock $VMMShutdown -ArgumentList $VMMServer, $VMName -Credential $Cred -Authentication Negotiate

        $VMMStart = {
                param ($VMMServer, $VMName)
                Start-Sleep 15
                Import-Module virtualmachinemanager
                $VM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $VMName
                Start-SCVirtualMachine -VM $VM | Out-Null
        }

        $CTXBlock = {
                param ($CTXServer, $VMName, $Solution)

                Add-PSSnapin Citrix.*

                ## Start with getting the ProvScheme data
                $ProvScheme = Get-ProvScheme -AdminAddress "$($CTXServer):80" | where{$_.MasterImageVM -like "XDHyp:\HostingUnits\CPO-HYP\$VMName.vm*"}

                $LoggingID = Start-LogHighLevelOperation -Source "SelfServiceSite" -Text "Update Image on Machine Catalog $($ProvScheme.ProvisioningSchemeName)"

                $SnapShot = New-HypVMSnapshot  -AdminAddress "$($CTXServer):80" -LiteralPath "XDHyp:\HostingUnits\CPO-HYP\$VMName.vm" -LoggingId $LoggingID.Id -SnapshotName "$(Get-Date -Format "dd-MM-yyyy HH:mm") - $Solution"

                Set-ProvSchemeMetadata  -AdminAddress "$($CTXServer):80" -LoggingId $LoggingID.Id -Name "ImageManagementPrep_DoImagePreparation" -ProvisioningSchemeName "$($ProvScheme.ProvisioningSchemeName)" -Value "True" | Out-Null

                $Publish = Publish-ProvMasterVMImage  -AdminAddress "$($CTXServer):80" -LoggingId $LoggingID.Id -MasterImageVM "$SnapShot" -ProvisioningSchemeName "$($ProvScheme.ProvisioningSchemeName)" -RunAsynchronously

                $TaskStatus = Get-ProvTask -TaskId $Publish.Guid

                While ( $TaskStatus.Active -eq $True ) {
                    Start-Sleep 15
                    $TaskStatus = Get-ProvTask -AdminAddress "$($CTXServer):80" -TaskId $Publish.Guid
                }

                ## Could be used for instant reboot/update
                #Start-BrokerRebootCycle  -AdminAddress $CTXServer -InputObject @("MCS - AdvoPlus") -LoggingId $LoggingID -RebootDuration 0 -WarningRepeatInterval 0 | Out-Null

                Start-BrokerNaturalRebootCycle -AdminAddress "$($CTXServer):80" -InputObject @("$($ProvScheme.ProvisioningSchemeName)") -LoggingId $LoggingID.Id | Out-Null

                Stop-LogHighLevelOperation -HighLevelOperationId $LoggingID.Id -IsSuccessful $True | Out-Null

                }

        Invoke-Command -ComputerName $CTXServer -ScriptBlock $CTXBlock -InDisconnectedSession -SessionName "Invoke" -ArgumentList $CTXServer, $VMName, $Solution -Credential $Cred -Authentication Negotiate

        ## Start the virtual machine again..
        Invoke-Command -ComputerName $VMMServer -ScriptBlock $VMMStart -ArgumentList $VMMServer, $VMName -Credential $Cred -Authentication Negotiate

        }
    elseif ($All) {

        $VMSB = {
            param($VMMServer)
            $VMS = Get-SCVirtualMachine -VMMServer $VMMServer | where{$_.Name -like "CPOAdvoGolden*" -or $_.Name -like "CPOLegalGolden*" -or $_.Name -like "CPO2015Golden*"} | sort name
            return $VMS
        }

        $VMNames = Invoke-Command -ComputerName $VMMServer -ScriptBlock $VMSB -ArgumentList $VMMServer -Credential $Cred -Authentication Negotiate

        foreach ($VMName in $VMNames.Name) {
            ## Start with shutting down all virtual machines. This is done before the snapshot is taking place..
            $VMMShutdown = {
                    param ($VMMServer, $VMName)

                    Import-Module virtualmachinemanager
                    $VM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $VMName

                    if ($VM.Status -eq "Running") {
                        Stop-SCVirtualMachine -VM $VM -Shutdown | Out-Null
                    }
                    #return $Latest.Name
            }
            ## Run invoke before CTXBlock so Latest variable will be filled..
            $Latest = Invoke-Command -ComputerName $VMMServer -ScriptBlock $VMMShutdown -ArgumentList $VMMServer, $VMName -Credential $Cred -Authentication Negotiate

            $VMMStart = {
                    param ($VMMServer, $VMName)
                    Start-Sleep 15
                    Import-Module virtualmachinemanager
                    $VM = Get-SCVirtualMachine -VMMServer $VMMServer -Name $VMName
                    Start-SCVirtualMachine -VM $VM | Out-Null
            }

            $CTXBlock = {
                    param ($CTXServer, $VMName)

                    Add-PSSnapin Citrix.*

                    ## Start with getting the ProvScheme data
                    $ProvScheme = Get-ProvScheme -AdminAddress "$($CTXServer):80" | where{$_.MasterImageVM -like "XDHyp:\HostingUnits\CPO-HYP\$VMName.vm*"}

                    $LoggingID = Start-LogHighLevelOperation -Source "SelfServiceSite" -Text "Update Image on Machine Catalog $($ProvScheme.ProvisioningSchemeName)"

                    $SnapShot = New-HypVMSnapshot -AdminAddress "$($CTXServer):80" -LiteralPath "XDHyp:\HostingUnits\CPO-HYP\$VMName.vm" -LoggingId $LoggingID.Id -SnapshotName "$(Get-Date -Format "dd-MM-yyyy HH:mm") - Auto checkpoint update"

                    Set-ProvSchemeMetadata -AdminAddress "$($CTXServer):80" -LoggingId $LoggingID.Id -Name "ImageManagementPrep_DoImagePreparation" -ProvisioningSchemeName "$($ProvScheme.ProvisioningSchemeName)" -Value "True" | Out-Null

                    $Publish = Publish-ProvMasterVMImage -AdminAddress "$($CTXServer):80" -LoggingId $LoggingID.Id -MasterImageVM "$SnapShot" -ProvisioningSchemeName "$($ProvScheme.ProvisioningSchemeName)" -RunAsynchronously

                    $TaskStatus = Get-ProvTask -TaskId $Publish.Guid

                    While ( $TaskStatus.Active -eq $True ) {
                        Start-Sleep 15
                        $TaskStatus = Get-ProvTask -AdminAddress "$($CTXServer):80" -TaskId $Publish.Guid
                    }

                    ## Could be used for instant reboot/update
                    #Start-BrokerRebootCycle  -AdminAddress $CTXServer -InputObject @("MCS - AdvoPlus") -LoggingId $LoggingID -RebootDuration 0 -WarningRepeatInterval 0 | Out-Null

                    Start-BrokerNaturalRebootCycle -AdminAddress "$($CTXServer):80" -InputObject @("$($ProvScheme.ProvisioningSchemeName)") -LoggingId $LoggingID.Id | Out-Null

                    Stop-LogHighLevelOperation -HighLevelOperationId $LoggingID.Id -IsSuccessful $True | Out-Null

                    }

            Invoke-Command -ComputerName $CTXServer -ScriptBlock $CTXBlock -InDisconnectedSession -SessionName "Invoke" -ArgumentList $CTXServer, $VMName -Credential $Cred -Authentication Negotiate

            ## Start the virtual machine again..
            Invoke-Command -ComputerName $VMMServer -ScriptBlock $VMMStart -ArgumentList $VMMServer, $VMName -Credential $Cred -Authentication Negotiate

            }
    }
}