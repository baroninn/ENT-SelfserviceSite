function Start-DirSync {
    [Cmdletbinding()]
    param(
    [string]$Organization
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2
        $Config = Get-EntConfig -Organization $Organization
        $Cred = Get-RemoteCredentials -Organization $Organization
    }
    Process {
        
        if ($Config.AADsynced -eq 'true') {
        
            $DirBlock = {
                try { 
                    Import-Module ADSync
                    Start-ADSyncSyncCycle -PolicyType delta
                }
                catch {
                    Write-Verbose "Error : $_"
                }
            }
            Invoke-Command -ComputerName $Config.ADConnectServer -ScriptBlock $DirBlock -Credential $Cred | Out-Null
        }
        else {
            Write-Verbose "Customer is not Dirsynced according to conf.."
        }
    }
}