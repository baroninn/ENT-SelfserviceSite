function New-LegalWebServiceInstance {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$CompanyName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$WebServicePath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$WebServiceLogPath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$LogWriter,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ComputerName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Force,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Remove,

        [string]$ServerInstance = $TenantName
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        [pscredential]$RemoteCredential = Get-RemoteCredentials -CPO
    }

    Process {
        $configName = 'nlog.config'

        $webServiceScriptBlock = {
            param (
                [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [string]$TenantName,

                [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [string]$WebServiceLogPath,

                [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [string]$CompanyName,

                [Parameter(ValueFromPipelineByPropertyName)]
                [bool]$Force,

                [Parameter(ValueFromPipelineByPropertyName)]
                [bool]$Remove = $False
            )

            $ErrorActionPreference = 'Stop'
            Set-StrictMode -Version 2.0

            $webApp = @(Get-WebApplication -Name $TenantName)

            if ($webApp.Count -gt 0 -and -not $Force -and -not $Remove) {
                Write-Error "Legal Web Service has already been created for '$TenantName'."
            }
            if (-not $webApp -and -not $Force -and -not $Remove) {

            Import-Module C:\CaptoInstall\NAV.psm1

            New-LegalOfficeServerInstance -NAVServer $TenantName -NAVInstance $TenantName -CompanyName $CompanyName
            }
            
            if ($Force -and -not $Remove) {
                
                try{Remove-WebApplication -Name $TenantName -Site "Legal Web Services - 81" -ErrorAction SilentlyContinue}catch{}
                try{Get-ChildItem -Path "C:\inetpub\Legal Web Services - 81\$TenantName*" | Remove-Item -Recurse -Force}catch{}
                try{Get-ChildItem -Path "C:\ProgramData\Capto\Repository Service\Logs\$TenantName*" | Remove-Item -Recurse -Force}catch{}

                    Import-Module C:\CaptoInstall\NAV.psm1

                    New-LegalOfficeServerInstance -NAVServer $TenantName -NAVInstance $TenantName -CompanyName $CompanyName
            }

            if ($Remove) {
                
                try{Remove-WebApplication -Name $TenantName -Site "Legal Web Services - 81" -ErrorAction SilentlyContinue}catch{}
                try{Get-ChildItem -Path "C:\inetpub\Legal Web Services - 81\$TenantName*" | Remove-Item -Recurse -Force}catch{}
                try{Get-ChildItem -Path "C:\ProgramData\Capto\Repository Service\Logs\$TenantName*" | Remove-Item -Recurse -Force}catch{}
            }
            
        }

        if ($ComputerName) {
            $testPath    = "\\$ComputerName\$WebServicePath".Replace(':', '$')
            $testLogPath = "\\$ComputerName\$WebServiceLogPath".Replace(':', '$')
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $webServiceScriptBlock -ArgumentList $ServerInstance, $WebServiceLogPath, $CompanyName, $Force, $Remove -Authentication Kerberos -Credential $RemoteCredential
        }
        else {
            $testPath    = $WebServicePath
            $testLogPath = $WebServiceLogPath
            Invoke-Command -ScriptBlock $webServiceScriptBlock -ArgumentList $ServerInstance, $WebServiceLogPath, $CompanyName, $Force -Authentication Kerberos -Credential $RemoteCredential
        }

        if(-not $Remove){

            if (-not (Test-Path $testPath)) {
                Write-Error "WebServicePath '$testPath' was not found"
            }
            if (-not (Test-Path $testLogPath)) {
                Write-Error "WebServiceLogPath '$testLogPath' was not found"
            }

            $tenantPath       = Join-Path $testPath $ServerInstance
            $tenantConfigFile = Join-Path $tenantPath $configName
            $tenantLogPath    = Join-Path $testLogPath $ServerInstance
            Write-Verbose "Creating folder '$tenantLogPath'..."
            New-Item -Path $tenantLogPath -ItemType Directory | Out-Null

            $aclParams = @{
                Path              = $tenantLogPath 
                FileSystemRights  = 'Modify'
                AccessControlType = 'Allow'
                InheritanceFlags  = 'ContainerInherit','ObjectInherit'
                PropagationFlags  = 'None'
            }

            try {
                $aclParams.Add('SecurityIdentifier', [System.Security.Principal.SecurityIdentifier]$LogWriter)
            }
            catch {
                $aclParams.Add('User', $LogWriter )
            }

            Add-AclEntry @aclParams

            Write-Verbose "Setting $configName log filename..."
            [xml]$xml = Get-Content -Path $tenantConfigFile
            $xml.nlog.targets.target.target.fileName = "`${environment:variable=ALLUSERSPROFILE}\Capto\Repository Service\Logs\$ServerInstance\`${shortdate}.txt"
            $xml.Save($tenantConfigFile)
        }
    }
}