function Close-ExchangeProxyModule {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    $sessionName = $Organization

    # Remove the module/session from this scope, to avoid it getting stuck in the users scope.
    Get-Module -Name "tmp_*" | Remove-Module
    $Session = Get-PSSession -Name $sessionName -ErrorAction SilentlyContinue
    Remove-PSSession -Session $Session -Confirm:$false

}
