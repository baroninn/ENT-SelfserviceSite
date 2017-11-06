function Update-LegalGpoSettings {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="SQL")]
        [string]$DatabaseServer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$CompanyName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$GPOPath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$UsersOU,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DomainName,

        [bool]$Force
    )

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2.0

    $Config = Get-TenantConfig -TenantName $TenantName

    $registrySubPath = 'User\Preferences\Registry\Registry.xml'
    $shortcutSubPath = 'User\Preferences\Shortcuts\Shortcuts.xml'

    $registryPath = Join-Path $GpoPath $registrySubPath

    [xml]$registryXml = Get-Content -Path $registryPath

    if ($Config.Legal.GpoSet -and -not $Force) {
        Write-Error "This tenant has already had its GPO settings changed. You must use the Force parameter to continue."
    }

    #Remove-GPLink -Name $NativeGPOName -Target $UsersOU -Domain $DomainName -ErrorAction SilentlyContinue | Out-Null

    if ($PSCmdlet.ParameterSetName -eq "SQL") {
        @(@($registryXml.RegistrySettings.Collection).Where{$_.Name -eq 'AdvoForum'}.Registry).Where{$_.Name -eq 'NavBaseAddress'}.Properties.value = "http://$($TenantName):7047/$TenantName/WS/$CompanyName"
        $registryXml.Save($registryPath)
    }
    else {
        Write-Error "Unknown ParameterSetName '$($PSCmdlet.ParameterSetName)'"
    }

    Set-TenantConfig -TenantName $TenantName -LegalGpoSet $true -Product $Config.Product.Name
}