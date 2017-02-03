function Resolve-Domain {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ParameterSetName="UserPrincipalName")]
        [string]$UserPrincipalName
    )

    if ($UserPrincipalName.IndexOf('@') -eq -1) {
        Write-Error "UserPrincipalName '$UserPrincipalName' does not contain '@'."
    }

    $UserPrincipalName.Substring($UserPrincipalName.IndexOf('@')+1)
}