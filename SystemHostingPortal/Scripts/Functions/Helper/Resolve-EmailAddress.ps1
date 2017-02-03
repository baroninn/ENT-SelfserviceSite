function Resolve-EmailAddress {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Value
    )

    if ($Value.IndexOf('@') -ne -1) {
        $alias  = $Value.Substring(0, $Value.IndexOf('@'))
        $domain = $Value.Substring($Value.IndexOf('@') + 1)
        if ($alias -eq $null -or $alias -eq '') {
            Write-Error "Value '$Value' does not have a valid alias."
        }
        elseif ($domain -eq $null -or $domain -eq '') {
            Write-Error "Value '$Value' does not have a valid domain."
        }
    }
    else {
        Write-Error "Value '$Value' is not a valid e-mail address."
    }

    [pscustomobject]@{
        Alias  = $alias
        Domain = $domain
    }
}