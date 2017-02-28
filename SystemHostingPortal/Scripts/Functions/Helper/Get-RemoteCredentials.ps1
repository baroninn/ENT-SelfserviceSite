function Get-RemoteCredentials {
    [Cmdletbinding()]
    param(
    [switch]$Organization
    )
    Begin {
        $KeyFile          = "C:\scriptstest\AES.key"
    }
    Process {

            $User             = "CORP\SVC_$($Organization)_ENTCon"
            $File             = "C:\ENTscripts\Password.txt"
            $key              = Get-Content $KeyFile
            $Credential       = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString -Key $key)

            return $Credential
    }
    
}
