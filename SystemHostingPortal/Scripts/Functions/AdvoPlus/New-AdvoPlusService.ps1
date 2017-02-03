function New-AdvoPlusService {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DatabaseServer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DatabaseName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ServerInstance,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$RepositoryServer,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Domain = $env:USERDNSDOMAIN,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [pscredential]$ServiceAccount,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ComputerName,

        [switch]$SkipServiceCreation,

        [switch]$SkipFirewallRules
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $exeName    = 'Microsoft.Dynamics.Nav.Server.exe'
        $configName = 'CustomSettings.config'
    }

    Process {
        $serviceName = 'MicrosoftDynamicsNavWS${0}' -f $ServerInstance
        $serviceUser = Get-ADUser -Identity $ServiceAccount.GetNetworkCredential().UserName -Server $Domain

        if ($Path -like "\\*") {
            Write-Error "Path must not be an UNC"
        }

        if ($ComputerName) {
            $testPath = "\\$ComputerName\$Path".Replace(':', '$')
        }
        else {
            $testPath = $Path
        }

        $testConfigPath = Join-Path $testPath $configName

        if (-not (Test-Path $testPath)) {
            Write-Error "Path '$testPath' was not found"
        }
        elseif (-not (Test-Path $testConfigPath)) {
            Write-Error "Config file '$testConfigPath' was not found"
        }
        else {
            if ($testPath -like "*\$exeName") {
                $binPath = $Path
                $Path = $Path.Substring(0, $Path.LastIndexOf('\'))
            }
            else {
                $binPath = Join-Path $Path $exeName
                $testBinPath = Join-Path $testPath $exeName
                if (-not (Test-Path $testBinPath)) {
                    Write-Error "Executable file '$exeName' was not found in Path '$testPath'"
                }
            }
        }

        $serviceArgumentList = "Create `"$serviceName`" binpath= `"$binPath `$$ServerInstance`" Type= share DisplayName= `"NAV Server $ServerInstance WS`" obj= `"$($ServiceAccount.UserName)`" password= `"$($ServiceAccount.GetNetworkCredential().Password)`" start= AUTO depend= HTTP/NetTcpPortSharing"
        if (-not $SkipServiceCreation) {
            if ($ComputerName) {
                Start-ProcessWithErrorHandling -FilePath "sc" -ArgumentList $serviceArgumentList -ComputerName $ComputerName
            }
            else {
                Start-ProcessWithErrorHandling -FilePath "sc" -ArgumentList $serviceArgumentList
            }
        }

        if (-not $SkipFirewallRules) {
            Add-AdvoPlusWindowsFirewallRules -TenantName $ServerInstance -ServiceAccount $ServiceAccount -ComputerName $ComputerName
        }

        Write-Verbose "Loading config file '$testConfigPath'..."
        [xml]$xmlConfig = Get-Content -Path $testConfigPath

        $xmlConfig.appSettings.add.Where{$_.key -eq 'DatabaseServer'}[0].value = $DatabaseServer
        $xmlConfig.appSettings.add.Where{$_.key -eq 'DatabaseName'}[0].value = $DatabaseName
        $xmlConfig.appSettings.add.Where{$_.key -eq 'ServerInstance'}[0].value = $ServerInstance
        $xmlConfig.appSettings.add.Where{$_.key -eq 'WebServicesDefaultTimeZone'}[0].value = 'Server Time Zone'

        Write-Verbose "Saving config file '$testConfigPath'..."
        $xmlConfig.Save($testConfigPath)

        Write-Verbose "Setting 'SeServiceLogonRight' for $($ServiceAccount.UserName)..."
        if ($ComputerName) {
            Grant-UserRight -Account $serviceUser.SID.Value -Right SeServiceLogonRight -Computer $ComputerName
        }
        else {
            Grant-UserRight -Account $serviceUser.SID.Value -Right SeServiceLogonRight
        }

        Write-Verbose "Starting service '$serviceName'..."
        if ($ComputerName) {
            Get-Service -Name $serviceName -ComputerName $ComputerName | Start-Service
        }
        else {
            Get-Service -Name $serviceName | Start-Service
        }

        $setAdvoPlusRegistryScript = {
            param (
                $RepositoryServer,
                $TenantName,
                $ServiceAccount,
                $ServiceUser
            )

            $regPath = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$($ServiceUser.SID)\Software\Capto\Advo\Repository"
            New-Item -Path $regPath -ItemType Key -Force | Out-Null
            Set-ItemProperty -Path $regPath -Name BaseAddress -Value "http://$($RepositoryServer):81/$TenantName"
            Set-ItemProperty -Path $regPath -Name Ntlm -Value 1
            Set-ItemProperty -Path $regPath -Name Spn  -Value "HTTP/$($RepositoryServer)"

            $accessrule = New-Object System.Security.AccessControl.RegistryAccessRule ("Authenticated Users", "ReadKey", "ObjectInherit,ContainerInherit", "None", "Allow")
            $acl = Get-Acl -Path $regPath
            $acl.AddAccessRule($accessrule)
            Set-Acl -Path $regPath -AclObject $acl
        }

        Write-Verbose "Setting registry settings for '$($ServiceAccount.UserName)'..."
        if ($ComputerName) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $setAdvoPlusRegistryScript -ArgumentList $RepositoryServer, $ServerInstance, $ServiceAccount, $serviceUser
        }
        else {
            $setAdvoPlusRegistryScript.Invoke()
        }

        Write-Verbose "Restarting service '$serviceName'..."
        if ($ComputerName) {
            Get-Service -Name $serviceName -ComputerName $ComputerName | Restart-Service
        }
        else {
            Get-Service -Name $serviceName | Restart-Service
        }
    }
}