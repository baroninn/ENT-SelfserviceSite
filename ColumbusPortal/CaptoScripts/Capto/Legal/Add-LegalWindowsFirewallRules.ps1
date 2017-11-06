function Add-LegalWindowsFirewallRules {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='ServiceAccount')]
        [pscredential]$ServiceAccount,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='ServiceAccountName')]
        [string]$ServiceAccountName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ComputerName
    )

    $userName = if ($ServiceAccount) { $ServiceAccount.UserName } else { $ServiceAccountName }
    $argumentList = 'http add urlacl url=http://+:7047/"{0}" user="{1}"' -f $TenantName, $userName
    $argumentList2 = 'http add urlacl url=http://+:7048/"{0}" user="{1}"' -f $TenantName, $userName

    if ($ComputerName) {
        Start-ProcessWithErrorHandling -FilePath 'netsh' -ArgumentList $argumentList -ComputerName $ComputerName
        Start-ProcessWithErrorHandling -FilePath 'netsh' -ArgumentList $argumentList2 -ComputerName $ComputerName
    }
    else {
        Start-ProcessWithErrorHandling -FilePath 'netsh' -ArgumentList $argumentList
        Start-ProcessWithErrorHandling -FilePath 'netsh' -ArgumentList $argumentList2
    }
}