function Get-RemoteCredentials {
    [Cmdletbinding()]
    param(
    [switch]$CPO,
    [switch]$CORP
    )
    Begin {
        $KeyFile          = "C:\scriptstest\AES.key"
    }
    Process {

        if ($CPO) {
            $CaptoUser        = 'SVC_CPO_CredSSP@hosting.capto.dk'
            $CaptoFile        = "C:\scriptstest\SVC_CPO_CredSSP.txt"
            $KeyFile          = "C:\scriptstest\AES.key"
            $key              = Get-Content $KeyFile
            $CPOCredential    = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $CaptoUser, (Get-Content $CaptoFile | ConvertTo-SecureString -Key $key)

            return $CPOCredential
        }
        if ($CORP) {
            $CorpUser         = 'svc_selfservicecapto@corp.systemhosting.dk'
            $CorpFile         = "C:\scriptstest\SVC_selfservicecapto.txt"
            $KeyFile          = "C:\scriptstest\AES.key"
            $key              = Get-Content $KeyFile
            $CORPCredential   = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $CorpUser, (Get-Content $CorpFile | ConvertTo-SecureString -Key $key)

            return $CorpCredential
        }
    }
}
