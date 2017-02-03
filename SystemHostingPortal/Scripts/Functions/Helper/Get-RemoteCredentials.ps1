function Get-RemoteCredentials {
    [Cmdletbinding()]
    param(
    [switch]$Organization
    )
    Begin {
        $KeyFile          = "C:\scriptstest\AES.key"
    }
    Process {

        if ($Organization -eq 'PRV') {
            $User             = 'SVC_ENTConnection@corp.provinord.dk'
            $File             = "C:\scriptstest\PRV.txt"
            $key              = Get-Content $KeyFile
            $Credential       = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString -Key $key)

            return $Credential
        }
    }
}
