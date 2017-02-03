function Update-AdvoPlusGpoSettings {
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

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="Native")]
        [string]$NativeDatabaseServer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$UsersOU,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$NativeGPOName,

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
    $shortcutPath = Join-Path $GpoPath $shortcutSubPath

    [xml]$registryXml = Get-Content -Path $registryPath
    [xml]$shortcutXml = Get-Content -Path $shortcutPath

    if ($Config.AdvoPlus.GpoSet -and -not $Force) {
        Write-Error "This tenant has already had its GPO settings changed. You must use the Force parameter to continue."
    }

    Remove-GPLink -Name $NativeGPOName -Target $UsersOU -Domain $DomainName -ErrorAction SilentlyContinue | Out-Null

    if ($PSCmdlet.ParameterSetName -eq "SQL") {
        @(@($registryXml.RegistrySettings.Collection).Where{$_.Name -eq 'AdvoForum'}.Registry).Where{$_.Name -eq 'NavBaseAddress'}.Properties.value = "http://$($TenantName):7047/$TenantName/WS/$CompanyName"
        $registryXml.Save($registryPath)

        @($shortcutXml.Shortcuts.Shortcut).Where{$_.Name -eq 'AdvoPlus'}.Properties.arguments = "servername=$DatabaseServer,database=$TenantName,NTAuthentication=1,Company=`"$CompanyName`""
        @($shortcutXml.Shortcuts.Shortcut).Where{$_.Name -eq 'AdvoPlus'}.Properties.targetPath = "C:\Program Files (x86)\Microsoft Dynamics NAV\60\Classic\finsql.exe"
        @($shortcutXml.Shortcuts.Shortcut).Where{$_.Name -eq 'AdvoPlus'}.Properties.iconPath   = "C:\Program Files (x86)\Microsoft Dynamics NAV\60\Classic\finsql.exe"
        $shortcutXml.Save($shortcutPath)
    }
    elseif ($PSCmdlet.ParameterSetName -eq "Native") {
        @($shortcutXml.Shortcuts.Shortcut).Where{$_.Name -eq 'AdvoPlus'}.Properties.arguments  = "servername=$NativeDatabaseServer,Company=`"$CompanyName`",NetType=TCP"
        @($shortcutXml.Shortcuts.Shortcut).Where{$_.Name -eq 'AdvoPlus'}.Properties.targetPath = "C:\Program Files (x86)\Microsoft Dynamics NAV\60\Classic\fin.exe"
        @($shortcutXml.Shortcuts.Shortcut).Where{$_.Name -eq 'AdvoPlus'}.Properties.iconPath   = "C:\Program Files (x86)\Microsoft Dynamics NAV\60\Classic\fin.exe"
        $shortcutXml.Save($shortcutPath)

        $gpo = Get-GPO -Name $NativeGPOName -Domain $DomainName
        $gpo | New-GPLink -Target $UsersOU -Domain $DomainName | Out-Null
    }
    else {
        Write-Error "Unknown ParameterSetName '$($PSCmdlet.ParameterSetName)'"
    }

    Set-TenantConfig -TenantName $TenantName -AdvoPlusGpoSet $true -Product $Config.Product.Name
}