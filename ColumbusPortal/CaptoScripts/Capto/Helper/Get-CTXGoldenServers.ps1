Function Get-CTXGoldenServers {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("AdvoPlus", "Legal", "Member2015")]
        [string]$Solution,
        [switch]$MCSEnabled

    )
    Begin {

        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2
        $CTXServer = "cpo-ctx-01.hosting.capto.dk"
        $VMMServer= 'CPO-VMM-01.hosting.capto.dk'
        $Cred = Get-RemoteCredentials -CPO

    }
    Process {
        $VMMBlock = {
            param($VMMServer, $Solution)

            Import-Module virtualmachinemanager -Cmdlet Get-SCVirtualMachine -DisableNameChecking | Out-Null

            if ($Solution -eq "AdvoPlus") {
                $VMs = Get-SCVirtualMachine -VMMServer $VMMServer | where{$_.Name -like "*Advo*" -and $_.Name -like "*Golden*"} | Sort-Object Name
            }
            if ($Solution -eq "Legal") {
                $VMs = Get-SCVirtualMachine -VMMServer $VMMServer | where{$_.Name -like "*Legal*" -and $_.Name -like "*Golden*"} | Sort-Object Name
            }
            if ($Solution -eq "Member2015") {
                $VMs = Get-SCVirtualMachine -VMMServer $VMMServer | where{$_.Name -like "*2015*" -and $_.Name -like "*Golden*"} | Sort-Object Name
            }

            $Serverlist  = @()
            foreach ($vm in $VMs) {
                $Serverlist += 
                  [pscustomobject]@{
                      Name = $vm.Name
                  }
            }
            return $serverlist

        }

        $VMS = Invoke-Command -ComputerName $VMMServer -ScriptBlock $VMMBlock -ArgumentList $VMMServer, $Solution -Credential $Cred

        $CTXBlock = {
            param($VMS, $MCSEnabled)
            Add-PSSnapin Citrix.MachineCreation.Admin.V2 
            $Serverlist  = @()

            foreach ($vm in $VMS) {
                if ($MCSEnabled) {
                    $Exist = Get-ProvScheme | where {$_.MasterImageVM -like "XDHyp:\HostingUnits\CPO-HYP\$($VM.Name).vm*"} -ErrorAction SilentlyContinue
                    if ($Exist) {
                        $Serverlist += 
                        [pscustomobject]@{
                        Name       = $vm.Name
                        MCSEnabled = $True
                        }
                    }
                }
                else {
                    $Exist = Get-ProvScheme | where {$_.MasterImageVM -like "XDHyp:\HostingUnits\CPO-HYP\$($VM.Name).vm*"} -ErrorAction SilentlyContinue
                    if (!($Exist)) {
                        $Serverlist += 
                        [pscustomobject]@{
                        Name       = $vm.Name
                        MCSEnabled = $True
                        }
                    }
                }


            }
            return $Serverlist
        }

        $CTXVMS = Invoke-Command -ComputerName $CTXServer -ScriptBlock $CTXBlock -ArgumentList $VMS, $MCSEnabled -Credential $Cred
        return $CTXVMS

    }
}