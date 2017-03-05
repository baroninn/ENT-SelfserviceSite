function Get-RemoteCredentials {
    [Cmdletbinding()]
    param(
    [string]$Organization
    )
    Begin {
        $KeyFile          = "C:\scriptstest\AES.key"
        $Config = Get-EntConfig -Organization $Organization -JSON
    }
    Process {

            $User             = "SVC_$($Organization)_ENTCon@$($Config.DomainFQDN)"
            $File             = "C:\ENTscripts\Password.txt"
            $key              = Get-Content $KeyFile
            $Credential       = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString -Key $key)

            return $Credential
    }
    
}
