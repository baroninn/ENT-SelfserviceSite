function New-AdvoPlusMobileServerInstance {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$CompanyName,

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
        $mobileServiceScriptBlock = {
            param (
                [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [string]$TenantName,

                [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
                [string]$CompanyName,

                [Parameter(ValueFromPipelineByPropertyName)]
                [bool]$Force,

                [Parameter(ValueFromPipelineByPropertyName)]
                [bool]$Remove
            )

            $ErrorActionPreference = 'Stop'
            Set-StrictMode -Version 2.0

            $webApp = @(Get-WebApplication -Name $TenantName)

            if ($webApp.Count -gt 0 -and -not $Force -and -not $Remove) {
                Write-Error "AdvoPlus Mobile Service has already been created for '$TenantName'."
            }

            if (-not $webApp -and -not $Force -and -not $Remove) {

            Import-Module C:\SYSTEMHOSTING\CaptoInstall\NAV.psm1

            New-MobileServerInstance -NAVServer $TenantName -NAVInstance $TenantName -CompanyName $CompanyName
            }
            
            if ($Force -and -not $Remove) {
            
            try{Remove-WebApplication -Name $TenantName -Site "Advo Online - 443" -ErrorAction SilentlyContinue}catch{}
            try{Get-ChildItem -Path "C:\inetpub\Advo Online - 443\$TenantName*" | Remove-Item -Recurse -Force}catch{}

                Import-Module C:\SYSTEMHOSTING\CaptoInstall\NAV.psm1

                New-MobileServerInstance -NAVServer $TenantName -NAVInstance $TenantName -CompanyName $CompanyName
            }

            if ($Remove) {
            
            try{Remove-WebApplication -Name $TenantName -Site "Advo Online - 443" -ErrorAction SilentlyContinue}catch{}
            try{Get-ChildItem -Path "C:\inetpub\Advo Online - 443\$TenantName*" | Remove-Item -Recurse -Force}catch{}

            }
            
        }

        if ($ComputerName) {
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $mobileServiceScriptBlock -ArgumentList $TenantName, $CompanyName, $Force, $Remove -Authentication Credssp -Credential $RemoteCredential
        }
        else {
            Invoke-Command -ScriptBlock $mobileServiceScriptBlock -ArgumentList $TenantName, $CompanyName, $Force, $Remove -Authentication Credssp -Credential $RemoteCredential
        }
    }
}