function Remove-AdvoPlusWindowsFirewallRules {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ComputerName
    )

    $argumentList = 'http delete urlacl http://+:7047/"{0}"' -f $TenantName

    if ($ComputerName) {
        Start-ProcessWithErrorHandling -FilePath 'netsh' -ArgumentList $argumentList -ComputerName $ComputerName
    }
    else {
        Start-ProcessWithErrorHandling -FilePath 'netsh' -ArgumentList $argumentList
    }
}