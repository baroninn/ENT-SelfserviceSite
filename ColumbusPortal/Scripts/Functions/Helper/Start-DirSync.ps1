function Start-DirSync {
    [Cmdletbinding()]
    param(
    [string]$Organization,
    
    [Parameter(Mandatory)]
    [ValidateSet("initial", "delta")]
    [string]$Policy,

    [switch]$Force

    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2
        $Config = Get-SQLEntConfig -Organization $Organization
        $Cred = Get-RemoteCredentials -Organization $Organization
    }
    Process {
        
        if ($Config.AADsynced -eq 'true') {
        
            $DirBlock = {
                param(
                    $Policy, 
                    $Force
                )
                if (-not $Force) {
                    
                    try { 
                        Import-Module ADSync
                        Start-ADSyncSyncCycle -PolicyType $Policy > $null
                    }
                    catch {
                        throw "Error : $_"
                    }
                }
                else {
                    try { 

                        Get-Service ADSync | Restart-Service -Force
                        $process = Get-Process miisclient -ErrorAction SilentlyContinue
                        if ($process) {
                            $process | Stop-Process -Force
                        }

                        Import-Module ADSync
                        Start-ADSyncSyncCycle -PolicyType $Policy > $null

                    }
                    catch {
                        throw "Error : $_"
                    }
                }
            }

            Invoke-Command -ComputerName $Config.ADConnectServer -ScriptBlock $DirBlock -Credential $Cred -ArgumentList $Policy, $Force
        }
        else {
            Write-Verbose "Customer is not Dirsynced according to conf.."
        }
    }
}