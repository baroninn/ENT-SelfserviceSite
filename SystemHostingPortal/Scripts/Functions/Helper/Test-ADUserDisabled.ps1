function Test-ADUserDisabled {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $DistinguishedName,

        [string]$Server = $env:USERDNSDOMAIN
    )
    Begin {
    }
    Process {
        $de = [ADSI]("LDAP://$Server/{0}" -f $DistinguishedName)
        $uac = [int]$de.Properties["userAccountControl"].Value

        $de.Close()

        return ($uac -band 2) -eq 2
    }
}