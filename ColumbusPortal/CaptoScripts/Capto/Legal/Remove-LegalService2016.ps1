function Remove-LegalService2016
{
    [CmdletBinding()]
    param (
        # NST
        [parameter(Mandatory=$true)]
        [string]$ServerInstance,
        
        [parameter(Mandatory=$true)]
        [string]$ComputerName

    )
    BEGIN
    {
        $RemoteCredential = Get-RemoteCredentials -CPO
    }
    PROCESS 
    {
        $Scriptblock = {
            param($ServerInstance)

    	    Import-Module "C:\Program Files\Microsoft Dynamics NAV\90\Service\NavAdminToolCapto.ps1" | Out-Null

            $ServiceName = ("MicrosoftDynamicsNavServer$" + $ServerInstance) 

            #Stop service 
            Get-Service $ServiceName | Stop-Service -Force
            Get-Service $ServiceName | Set-Service -StartupType Disabled   


            Remove-NAVServerInstance -ServerInstance $ServerInstance -Force
        }
    Write-Verbose "Removing Nav 2016 instance on $ComputerName"
    Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptblock -ArgumentList $ServerInstance

    }
}
