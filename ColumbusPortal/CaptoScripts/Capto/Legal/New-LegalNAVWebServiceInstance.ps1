function New-LegalNAVWebServiceInstance {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ComputerName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Force,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$Remove

    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        [pscredential]$RemoteCredential = Get-RemoteCredentials -CPO
    }

    Process {
        $configName = 'web.config'
        ## Nav webservice (Nav repository)
        $NAVwebServiceScriptBlock = {
            param (
                [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [string]$TenantName,

                [Parameter(ValueFromPipelineByPropertyName)]
                [bool]$Force = $False,

                [Parameter(ValueFromPipelineByPropertyName)]
                [bool]$Remove = $False
            )

            $ErrorActionPreference = 'Stop'
            Set-StrictMode -Version 2.0

            $webApp = @(Get-WebApplication -Name "$($TenantName)/WebClient")

            if ($webApp.Count -gt 0 -and -not $Force -and -not $Remove) {
                Write-Error "Nav Web Service has already been created for '$TenantName'."
            }
            if (-not $webApp -and -not $Force -and -not $Remove) {

            Import-Module ("C:\Program Files\Microsoft Dynamics NAV\90\Web Client\bin\Microsoft.Dynamics.Nav.Management.dll")
            
            New-NAVWebServerInstance -WebServerInstance $TenantName -Server $TenantName -ServerInstance $TenantName

            }
            
            if ($Force -and -not $Remove) {
                
                Import-Module ("C:\Program Files\Microsoft Dynamics NAV\90\Web Client\bin\Microsoft.Dynamics.Nav.Management.dll")

                try{Remove-NAVWebServerInstance -WebServerInstance $TenantName -Confirm:$false -Force}catch{}
                #try{Get-ChildItem -Path "C:\inetpub\wwwroot\$TenantName*" | Remove-Item -Recurse -Force}catch{}

                New-NAVWebServerInstance -WebServerInstance $TenantName -Server $TenantName -ServerInstance $TenantName -Force
            }

            if ($Remove) {
                
                Import-Module ("C:\Program Files\Microsoft Dynamics NAV\90\Web Client\bin\Microsoft.Dynamics.Nav.Management.dll")
                try{Remove-NAVWebServerInstance -WebServerInstance $TenantName -Confirm:$false -Force}catch{ throw $_}
                #try{Get-ChildItem -Path "C:\inetpub\wwwroot\$TenantName*" | Remove-Item -Recurse -Force}catch{ throw $_}
            }
            
        }

        if ($ComputerName) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $NAVwebServiceScriptBlock -ArgumentList $TenantName, $Force, $Remove -Authentication Negotiate -Credential $RemoteCredential
        }
        else {
            Invoke-Command -ScriptBlock $NAVwebServiceScriptBlock -ArgumentList $TenantName, $Force, $Remove -Authentication Negotiate -Credential $RemoteCredential
        }

        if(-not $Remove){

            $Configblock = {
                param(
                $TenantName, 
                $configName
                )

                Write-Verbose "Setting $configName log filename..."
                [xml]$xml = Get-Content -Path ("C:\inetpub\wwwroot\$($TenantName)\$($configName)")
                ($xml.DocumentElement.DynamicsNAVSettings.add | where{$_.key -like "AllowNtlm"}).value = "false"
                ($xml.DocumentElement.DynamicsNAVSettings.add | where{$_.key -like "Server"}).value = "$($TenantName)"
                ($xml.DocumentElement.DynamicsNAVSettings.add | where{$_.key -like "ServerInstance"}).value = "$($TenantName)"
                ($xml.DocumentElement.DynamicsNAVSettings.add | where{$_.key -like "UnknownSpnHint"}).value = "(net.tcp://$($TenantName):7046/$($TenantName)/Service)=NoSpn"
                $xml.Save("C:\inetpub\wwwroot\$($TenantName)\$($configName)")
            }

            if ($ComputerName) {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock $Configblock -ArgumentList $TenantName, $configName -Authentication Negotiate -Credential $RemoteCredential            }
            else {
                Invoke-Command -ScriptBlock $Configblock -ArgumentList $TenantName, $configName -Authentication Negotiate -Credential $RemoteCredential            
            }
        }
    }
}