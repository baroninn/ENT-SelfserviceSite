﻿function Get-RemoteCredentials {
    [Cmdletbinding()]
    param(
    [string]$Organization,
    [switch]$SSS
    )
    Begin {
        $KeyFile          = "C:\scriptstest\AES.key"
        
    }
    Process {

        if ($Organization) {

            $Config = Get-EntConfig -Organization $Organization -JSON

            $User             = "SVC_$($Organization)_ENTCon@$($Config.DomainFQDN)"
            $File             = "C:\ENTscripts\Password.txt"
            $key              = Get-Content $KeyFile
            $Credential       = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString -Key $key)

            return $Credential
        }
        if ($SSS) { 
            
            $User             = "corp\svc_selfservicecapto"
            $File             = "C:\ENTscripts\SSSPassword.txt"
            $key              = Get-Content $KeyFile
            $Credential       = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString -Key $key)

            return $Credential
        }
    }
    
}