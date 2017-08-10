function Start-DirSync {
    [Cmdletbinding()]
    param(
    [string]$Organization,
    
    [Parameter(Mandatory)]
    [ValidateSet("initial", "delta")]
    [string]$Policy

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
                param($Policy)

                try { 
                    Import-Module ADSync
                    Start-ADSyncSyncCycle -PolicyType $Policy
                }
                catch {
                    Write-Verbose "Error : $_"
                }
            }
            Invoke-Command -ComputerName $Config.ADConnectServer -ScriptBlock $DirBlock -Credential $Cred -ArgumentList $Policy | Out-Null
        }
        else {
            Write-Verbose "Customer is not Dirsynced according to conf.."
        }
    }
}